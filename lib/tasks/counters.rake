# frozen_string_literal: true

namespace :counters do
  desc "Reset counter_cache for models."
  task reset: :environment do
    Domain.find_each { |domain| Domain.reset_counters(domain.id, :variables) }
    Subject.find_each { |subject| Subject.reset_counters(subject.id, :randomizations) }
    Design.find_each(&:recompute_variables_count!)
  end
end
