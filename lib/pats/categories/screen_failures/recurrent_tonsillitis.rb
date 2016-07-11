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

        def variable_name
          'ciw_recurrent_tonsillitis'
        end

        def subquery
          "NULLIF(response, '')::numeric = 1"
        end
      end
    end
  end
end
