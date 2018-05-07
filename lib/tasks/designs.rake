# frozen_string_literal: true

# TODO: Remove in v63.0.0
namespace :designs do
  desc "Migrate original design slugs."
  task migrate_slugs: :environment do
    Design.find_each do |design|
      design.update slug: design.survey_slug if design.survey_slug.present?
    end
  end
end
