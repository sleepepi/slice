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

        # 'ciw_cg_reason_not_interested'
        def variable_id
          14301
        end

        def subquery
          "#{database_value} = 11"
        end
      end
    end
  end
end
