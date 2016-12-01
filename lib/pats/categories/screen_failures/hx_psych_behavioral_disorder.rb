# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ScreenFailures
      # Defines psychiatric behavior disorder variable and associated subquery.
      class HxPsychBehavioralDisorder < Default
        def label
          'Psychiatric/Behavior disorder'
        end

        def variable_name
          'ciw_hx_psych_behavioral_disorder'
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
