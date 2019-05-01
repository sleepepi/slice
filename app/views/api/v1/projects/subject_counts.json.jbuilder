# frozen_string_literal: true

sites = @project.sites.order_number_and_name
if params[:sites] == "1"
  json.sites do
    json.array!(sites) do |site|
      json.extract! site, :id, :number_and_short_name, :number, :name
    end
  end
end

json.rows do
  json.array!(params[:expressions] || []) do |expression|
    engine = ::Engine::Engine.new(@project, @project.user)
    engine.run(expression)

    json.expression expression
    json.count engine.subjects_count

    if params[:sites] == "1"
      json.sites do
        json.array!(sites) do |site|
          json.site_id site.id
          json.count @project.subjects.where(id: engine.subject_ids, site: site).count
        end
      end
    end
  end
end
