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

        def variable_name
          'ciw_cg_reason_not_interested'
        end

        def subquery
          "NULLIF(value, '')::numeric = 8"
        end
      end
    end
  end
end
