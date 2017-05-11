# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Disinterested
      # Defines unable to complete screening psg variable and associated subquery.
      class UnableToCompleteScreeningPsg < Default
        def label
          'Unable to complete screening PSG'
        end

        # 'ciw_cg_reason_not_interested'
        def variable_id
          14301
        end

        def subquery
          "#{database_value} = 5"
        end
      end
    end
  end
end
