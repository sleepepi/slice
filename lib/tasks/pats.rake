# frozen_string_literal: true

require 'pats'
include Pats

namespace :pats do
  desc 'Export recruitment data.'
  task recruitment: :environment do
    recruitment = {}
    slug = 'pats'
    project = Project.current.find_by_slug slug
    start_date = Date.parse('2016-06-01')
    if project
      recruitment[:screened] = screened_graph(project, start_date)
      recruitment[:screened][:table] = screened_table(project, start_date)
      recruitment[:consented] = consented_graph(project, start_date)
      recruitment[:consented][:table] = consented_table(project, start_date)
      recruitment[:eligible] = eligible_graph(project, start_date)
      recruitment[:eligible][:table] = eligible_table(project, start_date)
      recruitment[:randomized] = randomized_graph(project, start_date)
      recruitment[:randomized][:table] = randomized_table(project, start_date)
      recruitment[:demographics] = {}
      recruitment[:demographics][:screened] = demographics_screened(project)
      recruitment[:demographics][:consented] = demographics_consented(project)
      recruitment[:demographics][:eligible] = demographics_eligible(project)
      recruitment[:demographics][:randomized] = demographics_randomized(project)
      recruitment[:eligibility_status] = eligibility_status(project)

      recruitment[:exported_at] = Time.zone.now
      recruitment_json_file = Rails.root.join('pats', 'recruitment.json')
      File.open(recruitment_json_file, 'w') do |f|
        f.write(recruitment.to_json)
      end
      puts 'Wrote file to: ' + recruitment_json_file.to_s.colorize(:green)
    else
      puts 'Unable to load project: ' + slug.colorize(:red)
    end
  end
end

