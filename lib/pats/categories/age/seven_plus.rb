# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Age
      # Defines age from 7+ variable and associated subquery.
      class SevenPlus < Default
        def label
          '7 years or older'
        end

        # 'ciw_age_years'
        def variable_id
          13416
        end

        def subquery
          "#{database_value} >= 7"
        end
      end
    end
  end
end
