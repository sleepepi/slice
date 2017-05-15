# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Gender
      # Defines female variable and associated subquery.
      class Female < Default
        def label
          'Female'
        end

        # 'ciw_sex'
        def variable_id
          13419
        end

        def subquery
          "#{database_value} = 2"
        end
      end
    end
  end
end
