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

        def variable_name
          'ciw_cg_reason_not_interested'
        end

        def subquery
          "NULLIF(value, '')::numeric = 6"
        end
      end
    end
  end
end
