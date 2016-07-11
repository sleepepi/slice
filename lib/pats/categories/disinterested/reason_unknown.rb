# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Disinterested
      # Defines disinterest reason unknown variable and associated subquery.
      class ReasonUnknown < Default
        def label
          'Reason Unknown'
        end

        def variable_name
          'ciw_cg_reason_not_interested'
        end

        def subquery
          "NULLIF(value, '')::numeric IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)"
        end

        def css_class
          'lighter'
        end

        def inverse
          true
        end
      end
    end
  end
end
