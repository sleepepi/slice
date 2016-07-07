# frozen_string_literal: true

require 'pats/demographics'
require 'pats/screened'
require 'pats/consented'
require 'pats/eligible'
require 'pats/randomized'

# Helps export data from PATS project for display on patstrial.org.
module Pats
  include Pats::Demographics
  include Pats::Screened
  include Pats::Consented
  include Pats::Eligible
  include Pats::Randomized
end
