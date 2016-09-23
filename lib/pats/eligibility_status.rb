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
      tables = generic_eligibility_status(project, screened_sheets(project))
      { tables: tables }
    end

    def eligibility_status_consented(project)
      sheets = consented_sheets(project)
      tables = generic_eligibility_status_consented(project, sheets)
      consented = count_subjects(sheets)
      consented_ineligible = count_subjects(filter_sheets_by_category(project, sheets, 'ineligible'))
      consented_fully_eligible = count_subjects(filter_sheets_by_category(project, sheets, 'fully-eligible'))
      consented_pending_eligibility = consented - consented_ineligible - consented_fully_eligible
      consented_randomized = count_subjects(randomizations(project))
      consented_pending_randomization = consented_fully_eligible - consented_randomized
      {
        tables: tables,
        consented: consented,
        consented_ineligible: consented_ineligible,
        consented_fully_eligible: consented_fully_eligible,
        consented_pending_eligibility: consented_pending_eligibility,
        consented_pending_randomization: consented_pending_randomization,
        consented_randomized: consented_randomized
      }
    end

    def generic_eligibility_status(project, sheets)
      tables = []
      tables << demographics_table(project, sheets, 'eligibility')

      screen_failure_sheets = filter_sheets_by_category(project, sheets, 'ineligible')
      tables << demographics_table(project, screen_failure_sheets, 'screen-failures')

      ent_sheets = filter_sheets_by_category(project, screen_failure_sheets, 'ent-eligibility-not-met')
      tables << demographics_table(project, ent_sheets, 'ent-failures')

      psg_sheets = filter_sheets_by_category(project, screen_failure_sheets, 'psg-eligibility-not-met')
      tables << demographics_table(project, psg_sheets, 'psg-failures')

      not_interested_in_participation_sheets = filter_sheets_by_category(project, sheets, 'caregiver-not-interested')
      tables << demographics_table(project, not_interested_in_participation_sheets, 'not-interested-in-participation')
      tables
    end

    def generic_eligibility_status_consented(project, sheets)
      tables = []
      tables << demographics_table(project, sheets, 'eligibility-consented')

      screen_failure_sheets = filter_sheets_by_category(project, sheets, 'ineligible')
      tables << demographics_table(project, screen_failure_sheets, 'screen-failures-consented')

      ent_sheets = filter_sheets_by_category(project, screen_failure_sheets, 'ent-eligibility-not-met')
      tables << demographics_table(project, ent_sheets, 'ent-failures')

      psg_sheets = filter_sheets_by_category(project, screen_failure_sheets, 'psg-eligibility-not-met')
      tables << demographics_table(project, psg_sheets, 'psg-failures')
      tables
    end
  end
end
