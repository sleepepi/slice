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
      sheets = screened_sheets(project)
      tables = %w(eligibility).collect do |characteristic_type|
        demographics_table(project, sheets, characteristic_type)
      end
      { tables: tables }
    end
  end
end
