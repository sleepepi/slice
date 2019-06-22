# frozen_string_literal: true

sites = @project.sites.order_number_and_name
if params[:sites] == "1"
  json.sites do
    json.array!(sites) do |site|
      json.extract! site, :id, :number_and_short_name, :number, :name
    end
  end
end

engine = ::Engine::Engine.new(@project, @project.user)
engine.run([params[:filter], params[:group]].reject(&:blank?).join(" and "))

subject_site_map = @project.subjects.where(id: engine.subject_ids).pluck(:id, :site_id).to_h

site_dates = engine.interpreter.sobjects.collect do |_key, sobject|
  d = sobject.cells.find { |k, _| k == "_v_#{params[:group]}" }.second.collect(&:value).first
  [subject_site_map[sobject.subject_id], Date.parse(d)]
end

site_dates.sort_by!(&:second)

current_date = site_dates.first&.second&.beginning_of_month

dates = []
if current_date
  # Prevent dates with typos (ie 1017-01-01 instead of 2017-01-01) from creating too many rows.
  current_date = [Date.parse("2000-02-01"), current_date].max

  current_date -= 1.month # Start one month earlier
  while current_date <= Time.zone.today
    dates << current_date
    current_date += 1.month
  end
end

json.count site_dates.size

json.rows do
  json.array!(dates.reverse) do |date|
    month_results = site_dates.select do |_site_id, grouped_at|
      grouped_at.year == date.year && grouped_at.month == date.month
    end

    json.label date.strftime("%b '%y")

    json.count month_results.size

    if params[:sites] == "1"
      json.sites do
        json.array!(sites) do |site|
          json.site_id site.id
          json.count month_results.count { |site_id, _grouped_at| site_id == site.id }
        end
      end
    end
  end
end
