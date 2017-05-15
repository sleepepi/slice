# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Disinterested
      # Defines too difficult traveling to appointments variable and associated subquery.
      class TooDifficultTravelingToAppointments < Default
        def label
          'Too difficult traveling to appointments'
        end

        # 'ciw_cg_reason_not_interested'
        def variable_id
          14301
        end

        def subquery
          "#{database_value} = 2"
        end
      end
    end
  end
end
