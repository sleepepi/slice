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

        def variable_name
          'ciw_cg_reason_not_interested'
        end

        def subquery
          "#{database_value} = 7"
        end
      end
    end
  end
end
