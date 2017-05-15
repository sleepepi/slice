# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Disinterested
      # Defines study compensation too low variable and associated subquery.
      class StudyCompensationTooLow < Default
        def label
          'Study compensation too low'
        end

        # 'ciw_cg_reason_not_interested'
        def variable_id
          14301
        end

        def subquery
          "#{database_value} = 3"
        end
      end
    end
  end
end
