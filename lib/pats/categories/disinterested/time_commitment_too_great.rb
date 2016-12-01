# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Disinterested
      # Defines time commitment too great variable and associated subquery.
      class TimeCommitmentTooGreat < Default
        def label
          'Time commitment too great'
        end

        def variable_name
          'ciw_cg_reason_not_interested'
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
