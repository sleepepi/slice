# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Disinterested
      # Defines caregiver disinterested for other reasons.
      class OtherReasons < Default
        def label
          'Other reason(s)'
        end

        def variable_name
          'ciw_cg_reason_not_interested'
        end

        def subquery
          "#{database_value} = 11"
        end
      end
    end
  end
end
