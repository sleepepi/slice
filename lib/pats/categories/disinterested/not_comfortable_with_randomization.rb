# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Disinterested
      # Defines not comfortable with randomization variable and associated subquery.
      class NotComfortableWithRandomization < Default
        def label
          'Not comfortable with randomization'
        end

        def variable_name
          'ciw_cg_reason_not_interested'
        end

        def subquery
          "NULLIF(value, '')::numeric = 4"
        end
      end
    end
  end
end
