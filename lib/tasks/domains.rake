# frozen_string_literal: true

namespace :domains do
  desc 'Check validity of all sheets'
  task migrate_options: :environment do
    Domain.find_each do |domain|
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
  end
end
