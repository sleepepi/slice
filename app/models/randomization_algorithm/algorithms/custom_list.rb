# frozen_string_literal: true

module RandomizationAlgorithm
  module Algorithms
    # Handles list creation and randomization for minimization randomization
    # schemes.
    class CustomList < StratifiedLists
      def randomization_error_message
        "Next assignment has not been set by a project editor."
      end

      def randomize_subject_to_list!(subject, list, current_user, criteria_pairs)
        randomization = list.randomizations.where(subject_id: nil).order(:id).first
        if randomization
          randomization.add_subject!(subject, current_user)
          add_randomization_characteristics!(randomization, criteria_pairs)
        end
        randomization
      end
    end
  end
end
