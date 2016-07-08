# frozen_string_literal: true

require 'pats/core'
require 'pats/demographics'
require 'pats/categories'
require 'pats/characteristics'

module Pats
  # Exports demographics statistics for subjects on PATS.
  module EligibilityStatus
    include Pats::Core
    include Pats::Demographics

    def eligibility_status(project)
      tables = []
      sheets = screened_sheets(project)
      tables << demographics_table(project, sheets, 'eligibility')
      screen_failure_sheets = filter_sheets_by_category(project, sheets, 'ineligible')
      tables << demographics_table(project, screen_failure_sheets, 'screen-failures')
      { tables: tables }
    end
  end
end
