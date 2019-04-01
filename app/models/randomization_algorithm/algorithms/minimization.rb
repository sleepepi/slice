# frozen_string_literal: true

module RandomizationAlgorithm
  module Algorithms
    # Handles list creation and randomization for minimization randomization
    # schemes.
    class Minimization < OneListOrListsBySite
      attr_reader :randomization_scheme

      def randomize_subject_to_list!(subject, list, current_user, criteria_pairs)
        # Remove any blank randomizations
        list.randomizations.where(subject_id: nil).destroy_all
        # Create a dynamic randomization
        randomization = generate_next_randomization!(list, current_user, criteria_pairs)
        if randomization
          randomization.add_subject!(subject, current_user)
          add_randomization_characteristics!(randomization, criteria_pairs)
        end
        randomization
      end

      protected

      def generate_next_randomization!(list, current_user, criteria_pairs)
        criteria_pairs.collect! { |sfid, oid| [sfid.to_i, oid.to_i] }
        return nil unless all_criteria_selected?(criteria_pairs)
        # If 30% chance, select random treatment arm
        dice_roll = rand(100)
        dice_roll_cutoff = @randomization_scheme.chance_of_random_treatment_arm_selection
        past_distributions = {}
        weighted_eligible_arms = nil
        if dice_roll < dice_roll_cutoff
          (treatment_arm, weighted_eligible_arms) = select_random_treatment_arm
        else
          (treatment_arm, weighted_eligible_arms, past_distributions) = get_treatment_arm(list, criteria_pairs)
        end
        randomization = nil
        if treatment_arm && weighted_eligible_arms.is_a?(Array)
          randomization = list.randomizations.create(
            project_id: @randomization_scheme.project_id,
            randomization_scheme_id: @randomization_scheme.id,
            user_id: current_user.id,
            treatment_arm_id: treatment_arm.id,
            dice_roll: dice_roll,
            dice_roll_cutoff: dice_roll_cutoff,
            past_distributions: past_distributions,
            weighted_eligible_arms: weighted_eligible_arms.collect { |arm| { name: arm.name, id: arm.id } }
                                                          .sort { |a, b| a[:name] <=> b[:name] }
          )
        end
        randomization
      end

      def get_treatment_arm(list, criteria_pairs)
        all_criteria_selected = true
        past_distributions = {}
        randomization_scope = list.randomizations
        treatment_arms_and_counts = []
        non_site_stratification_factors = @randomization_scheme.stratification_factors.where(stratifies_by_site: false)
        stratification_factor_counts = {}
        non_site_stratification_factors.each do |sf|
          criteria = criteria_pairs.find { |sfid, _oid| sfid == sf.id }
          next unless criteria
          stratification_factor_counts[criteria.join("x")] ||= {}
          if sf.stratifies_by_site?
            site = @randomization_scheme.project.sites.find_by(id: criteria.last)
            stratification_factor_counts[criteria.join("x")][:name] = site.name if site
          else
            sfo = @randomization_scheme.stratification_factor_options.find_by(id: criteria.last)
            stratification_factor_counts[criteria.join("x")][:name] = sfo.label if sfo
          end
        end

        @randomization_scheme.treatment_arms.positive_allocation.order(:name).each do |treatment_arm|
          randomization_ids = []
          non_site_stratification_factors.each do |sf|
            criteria = criteria_pairs.find { |sfid, _oid| sfid == sf.id }
            unless criteria
              all_criteria_selected = false
              next
            end
            randomization_scope = list.randomizations.includes(:randomization_characteristics)
                                      .where.not(subject_id: nil)
                                      .where(treatment_arm_id: treatment_arm.id)
            criteria_randomization_ids = \
              if sf.stratifies_by_site?
                randomization_scope.where(
                  randomization_characteristics: {
                    stratification_factor_id: sf.id,
                    site_id: criteria.last
                  }
                ).pluck(:id)
              else
                randomization_scope.where(
                  randomization_characteristics: {
                    stratification_factor_id: sf.id,
                    stratification_factor_option_id: criteria.last
                  }
                ).pluck(:id)
              end
            stratification_factor_counts[criteria.join("x")][treatment_arm.id.to_s] = criteria_randomization_ids.count
            randomization_ids += criteria_randomization_ids
          end
          treatment_arms_and_counts << [treatment_arm, randomization_ids.count]
        end

        # Arms should be weighted by their allocation
        weighted_treatment_arms_and_counts = treatment_arms_and_counts.collect do |arm, count|
          [arm, (count / arm.allocation.to_f)]
        end

        # Compute past distributions
        past_distributions[:treatment_arms] = \
          @randomization_scheme.treatment_arms.positive_allocation.order(:name).collect do |arm|
            { name: arm.name, id: arm.id }
          end
        past_distributions[:stratification_factors] = []
        non_site_stratification_factors.each do |sf|
          sf_hash = {}
          criteria = criteria_pairs.find { |sfid, _oid| sfid == sf.id }
          if criteria
            name = stratification_factor_counts[criteria.join("x")][:name]
            sf_hash[:name] = name
            sf_hash[:criteria] = criteria
            sf_hash[:treatment_arm_counts] = []
            @randomization_scheme.treatment_arms.positive_allocation.order(:name).each do |treatment_arm|
              count = stratification_factor_counts[criteria.join("x")][treatment_arm.id.to_s]
              sf_hash[:treatment_arm_counts] << { count: count, treatment_arm_id: treatment_arm.id }
            end
          end
          past_distributions[:stratification_factors] << sf_hash
        end
        past_distributions[:totals] = treatment_arms_and_counts.collect do |arm, count|
          { count: count, treatment_arm_id: arm.id }
        end
        past_distributions[:weighted_totals] = weighted_treatment_arms_and_counts.collect do |arm, count|
          { count: count.round(2), treatment_arm_id: arm.id }
        end
        # End compute past distributions

        treatment_arm = nil
        weighted_eligible_arms = nil
        if all_criteria_selected
          min_value = weighted_treatment_arms_and_counts.collect { |_arm, count| count }.min
          eligible_arms = weighted_treatment_arms_and_counts.select { |_arm, count| count == min_value }
                                                            .collect { |arm, _count| arm }
          (treatment_arm, weighted_eligible_arms) = randomly_select_eligible_treatment_arm(eligible_arms)
        end
        [treatment_arm, weighted_eligible_arms, past_distributions]
      end

      def select_random_treatment_arm
        eligible_arms = @randomization_scheme.treatment_arms.positive_allocation
        randomly_select_eligible_treatment_arm(eligible_arms)
      end

      def randomly_select_eligible_treatment_arm(eligible_arms)
        weighted_eligible_arms = eligible_arms.collect { |arm| [arm] * arm.allocation }.flatten
        treatment_arm = weighted_eligible_arms[rand(weighted_eligible_arms.count)]
        [treatment_arm, weighted_eligible_arms]
      end
    end
  end
end
