# frozen_string_literal: true

namespace :languages do
  desc "Add Spanish to projects with translations enabled."
  task add_spanish: :environment do
    Project.where(translations_enabled: true).each do |project|
      project.project_languages.where(language_code: "es").first_or_create
    end
  end
end
