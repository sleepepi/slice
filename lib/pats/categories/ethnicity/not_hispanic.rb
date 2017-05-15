# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Ethnicity
      # Defines not hispanic variable and associated subquery.
      class NotHispanic < Default
        def label
          'Not Hispanic or Latino'
        end

        # 'ciw_ethnicity'
        def variable_id
          13422
        end

        def subquery
          "#{database_value} = 2"
        end
      end
    end
  end
end
