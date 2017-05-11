# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Ethnicity
      # Defines hispanic variable and associated subquery.
      class Hispanic < Default
        def label
          'Hispanic or Latino'
        end

        # 'ciw_ethnicity'
        def variable_id
          13422
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
