# frozen_string_literal: true

require 'pats/demographics'
require 'pats/screened'
require 'pats/consented'
require 'pats/eligible'
require 'pats/randomized'
require 'pats/eligibility_status'
require 'pats/data_quality'

# Helps export data from PATS project for display on patstrial.org.
module Pats
  include Pats::Demographics
  include Pats::Screened
  include Pats::Consented
  include Pats::Eligible
  include Pats::Randomized
  include Pats::EligibilityStatus
  include Pats::DataQuality
end
