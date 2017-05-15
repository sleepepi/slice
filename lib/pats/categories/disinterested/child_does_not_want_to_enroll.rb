# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Disinterested
      # Defines child does not want to enroll variable and associated subquery.
      class ChildDoesNotWantToEnroll < Default
        def label
          'Child does not want to enroll'
        end

        # 'ciw_cg_reason_not_interested'
        def variable_id
          14301
        end

        def subquery
          "#{database_value} = 8"
        end
      end
    end
  end
end
