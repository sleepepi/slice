# frozen_string_literal: true

namespace :domains do
  desc 'Migrate domain options'
  task migrate_options: :environment do
    total_domain_count = Domain.count
    Domain.find_each.with_index do |domain, index|
      print "\rUpdating domain #{index + 1} of #{total_domain_count}"
      domain.deprecated_options.each do |option|
        domain_option = domain.domain_options.create(
          name: option[:name],
          value: option[:value],
          description: option[:description],
          site_id: option[:site_id],
          missing_code: (option[:missing_code] == '1'),
          archived: false
        )
        domain_option.add_domain_option! unless domain_option.new_record?
      end
    end
    puts "\n"
  end
end
