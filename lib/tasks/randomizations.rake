# frozen_string_literal: true

namespace :randomizations do
  # TODO: Remove in 0.42.0
  desc 'Add site to all randomization characteristics'
  task add_site_characteristic: :environment do
    RandomizationCharacteristic.where(site_id: nil).find_each do |characteristic|
      next if characteristic.randomization.subject.nil?
      characteristic.update site_id: characteristic.randomization.subject.site_id
    end
  end
end
