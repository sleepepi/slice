# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Disinterested
      # Defines unable to complete other testing variable and associated subquery.
      class UnableToCompleteOtherTesting < Default
        def label
          'Unable to complete other testing'
        end

        # 'ciw_cg_reason_not_interested'
        def variable_id
          14301
        end

        def subquery
          "#{database_value} = 7"
        end
      end
    end
  end
end
