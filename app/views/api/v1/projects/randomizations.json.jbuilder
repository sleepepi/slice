# frozen_string_literal: true

sites = @project.sites.order_number_and_name
if params[:sites] == "1"
  json.sites do
    json.array!(sites) do |site|
      json.extract! site, :id, :number_and_short_name, :number, :name
    end
  end
end

randomizations = \
  @project.randomizations
          .includes(:subject)
          .where.not(randomized_at: nil)
          .order(:randomized_at)
          .pluck("subjects.site_id", :randomized_at)

current_date = randomizations.first&.second&.beginning_of_month

dates = []
if current_date
  while current_date <= Time.zone.today
    dates << current_date
    current_date += 1.month
  end
end

json.count randomizations.size

json.rows do
  json.array!(dates) do |date|
    month_randomizations = randomizations.select do |_site_id, randomized_at|
      randomized_at.year == date.year && randomized_at.month == date.month
    end

    json.label date.strftime("%b '%y")

    json.count month_randomizations.size

    if params[:sites] == "1"
      json.sites do
        json.array!(sites) do |site|
          json.site_id site.id
          json.count month_randomizations.count { |site_id, _randomized_at| site_id == site.id }
        end
      end
    end
  end
end
