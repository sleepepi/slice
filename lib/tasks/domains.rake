# frozen_string_literal: true

namespace :domains do
  desc 'Check validity of all sheets'
  task migrate_options: :environment do
    Domain.find_each do |domain|
      domain.deprecated_options.each do |option|
        domain.domain_options.create(
          name: option[:name],
          value: option[:value],
          description: option[:description],
          site_id: option[:site_id],
          missing_code: (option[:missing_code] == '1'),
          archived: false
        )
      end
    end
  end

  task size: :environment do
    Domain.find_each do |domain|
      if domain.deprecated_options.size != domain.domain_options.size
        puts domain.name
        puts domain.deprecated_options
        puts domain.domain_options.inspect
      end
    end
  end

  task valid: :environment do
    DomainOption.find_each do |o|
      puts o.inspect unless o.valid?
    end
  end
end
