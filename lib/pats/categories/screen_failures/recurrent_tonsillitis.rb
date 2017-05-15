# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ScreenFailures
      # Defines recurrent tonsillitis variable and associated subquery.
      class RecurrentTonsillitis < Default
        def label
          'Recurrent Tonsillitis'
        end

        # 'ciw_recurrent_tonsillitis'
        def variable_id
          13403
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
