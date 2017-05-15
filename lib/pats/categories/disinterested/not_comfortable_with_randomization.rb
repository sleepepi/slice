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

        # 'ciw_cg_reason_not_interested'
        def variable_id
          14301
        end

        def subquery
          "#{database_value} = 4"
        end
      end
    end
  end
end
