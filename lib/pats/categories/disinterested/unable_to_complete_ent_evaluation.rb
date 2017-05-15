# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Disinterested
      # Defines unable to complete ent evaluation variable and associated subquery.
      class UnableToCompleteEntEvaluation < Default
        def label
          'Unable to complete ENT evaluation'
        end

        # 'ciw_cg_reason_not_interested'
        def variable_id
          14301
        end

        def subquery
          "#{database_value} = 6"
        end
      end
    end
  end
end
