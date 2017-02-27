# frozen_string_literal: true

namespace :randomizations do
  # TODO: Remove in v0.51.0
  desc 'Reset Randomization Names'
  task reset_names: :environment do
    RandomizationScheme.find_each(&:reset_randomization_names!)
  end
end
