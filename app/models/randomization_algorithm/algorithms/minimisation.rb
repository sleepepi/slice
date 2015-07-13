module RandomizationAlgorithm

  class Minimisation < Default

    attr_reader :randomization_scheme

    def initialize(randomization_scheme)
      @randomization_scheme = randomization_scheme
    end

    # def randomization_error_message
    #   "Treatment Arms may not be set up correctly."
    # end

    def add_missing_lists!(current_user)
      if @randomization_scheme.lists.count == 0 and self.number_of_lists > 0 and self.number_of_lists < RandomizationScheme::MAX_LISTS
        @randomization_scheme.lists.create(project_id: @randomization_scheme.project_id, user_id: current_user.id)
      end
    end

    # def number_of_lists
    #   1
    # end

    # def find_list_by_option_hashes(option_hashes)
    #   criteria_pairs = option_hashes.collect{|h| [h[:stratification_factor_id], (h[:stratification_factor_option_id] || h[:site_id])]}
    #   self.find_list_by_criteria_pairs(criteria_pairs)
    # end

    # def find_list_by_criteria_pairs(criteria_pairs)
    #   @randomization_scheme.lists.first
    # end

    def randomize_subject_to_list!(subject, list, current_user, criteria_pairs)
      # Remove any blank randomizations
      list.randomizations.where(subject_id: nil).destroy_all

      # Create a dynamic randomization
      randomization = self.generate_next_randomization!(list, current_user, criteria_pairs)

      # Add subject to randomization list
      randomization.add_subject!(subject, current_user) if randomization
      randomization
    end

    protected

      def generate_next_randomization!(list, current_user, criteria_pairs)
        criteria_pairs.collect!{|sfid,oid| [sfid.to_i, oid.to_i]}

        @randomization_scheme.stratification_factors.each do |sf|
          unless criteria = criteria_pairs.select{|sfid, oid| sfid == sf.id}.first
            # Return if not all criteria pairs are selected
            return nil
          end
        end


        # If 30% chance, select random treatment arm
        arm_randomly_selected = false
        if rand(100) < 30
          treatment_arm = select_random_treatment_arm(list, criteria_pairs)
          arm_randomly_selected = true
        else
          treatment_arm = get_treatment_arm(list, criteria_pairs)
        end

        randomization = nil

        if treatment_arm
          randomization = list.randomizations.create(
            project_id: @randomization_scheme.project_id,
            randomization_scheme_id: @randomization_scheme.id,
            user_id: current_user.id,
            # arm_randomly_selected: arm_randomly_selected,
            treatment_arm_id: treatment_arm.id
          )
          @randomization_scheme.stratification_factors.each do |sf|
            if criteria = criteria_pairs.select{|sfid, oid| sfid == sf.id}.first
              if sf.stratifies_by_site?
                randomization.randomization_characteristics.create(
                  project_id: @randomization_scheme.project_id,
                  randomization_scheme_id: @randomization_scheme.id,
                  list_id: randomization.list_id,
                  stratification_factor_id: sf.id,
                  site_id: @randomization_scheme.project.sites.where(id: criteria.last).pluck(:id).first
                )
              else
                randomization.randomization_characteristics.create(
                  project_id: @randomization_scheme.project_id,
                  randomization_scheme_id: @randomization_scheme.id,
                  list_id: randomization.list_id,
                  stratification_factor_id: sf.id,
                  stratification_factor_option_id: sf.stratification_factor_options.where(id: criteria.last).pluck(:id).first
                )
              end
            end
          end
        end

        randomization
      end

      def get_treatment_arm(list, criteria_pairs)
        all_criteria_selected = true

        randomization_scope = list.randomizations
        treatment_arms_and_counts = []
        @randomization_scheme.treatment_arms.each do |treatment_arm|
          randomization_ids = []
          @randomization_scheme.stratification_factors.each do |sf|
            unless criteria = criteria_pairs.select{|sfid, oid| sfid == sf.id}.first
              all_criteria_selected = false
            end

            if criteria
              if sf.stratifies_by_site?
                randomization_ids += list.randomizations.includes(:randomization_characteristics).where.not(subject_id: nil).where(treatment_arm_id: treatment_arm.id).where(randomization_characteristics: { site_id: criteria.last }).pluck(:id)
              else
                randomization_ids += list.randomizations.includes(:randomization_characteristics).where.not(subject_id: nil).where(treatment_arm_id: treatment_arm.id).where(randomization_characteristics: { stratification_factor_option_id: criteria.last }).pluck(:id)
              end
            end
          end
          treatment_arms_and_counts << [treatment_arm, randomization_ids.uniq.count]
        end
        # Rails.logger.debug "TREATMENT ARMS AND COUNTS"
        # Rails.logger.debug "#{treatment_arms_and_counts.collect{|arm, count| "#{arm.name}: #{count}"}.inspect}"
        if all_criteria_selected
          min_value = treatment_arms_and_counts.collect{|arm, count| count}.min
          eligible_arms = treatment_arms_and_counts.select{|arm, count| count == min_value}.collect{|arm, count| arm}
          randomly_select_eligible_treatment_arm(eligible_arms)
        else
          nil
        end
      end

      def select_random_treatment_arm(list, criteria_pairs)
        eligible_arms = @randomization_scheme.treatment_arms.collect{|arm| [arm]*arm.allocation}.flatten
        randomly_select_eligible_treatment_arm(eligible_arms)
      end

      def randomly_select_eligible_treatment_arm(eligible_arms)
        eligible_arms[rand(eligible_arms.count)]
      end
  end

end
