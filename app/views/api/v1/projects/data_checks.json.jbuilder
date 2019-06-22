# frozen_string_literal: true

sites = @project.sites.order_number_and_name
if params[:sites] == "1"
  json.sites do
    json.array!(sites) do |site|
      json.extract! site, :id, :number_and_short_name, :number, :name
    end
  end
end

check_hashes = @project.checks.runnable.order(:name).collect do |check|
  total_count = check.status_checks.where(failed: true).joins(sheet: :subject).merge(Subject.current).count
  if params[:sites] == "1"
    site_hashes = sites.collect do |site|
      count = check.status_checks.where(failed: true).joins(sheet: :subject).merge(Subject.current.where(site: site)).count
      {
        site_id: site.id,
        count: count,
        link: "#{ENV["website_url"]}/projects/#{@project.to_param}/sheets?search=checks:#{check.to_param}&site_id=#{site.id}"
      }
    end

    {
      label: check.name,
      count: total_count,
      link: "#{ENV["website_url"]}/projects/#{@project.to_param}/sheets?search=checks:#{check.to_param}",
      sites: site_hashes
    }
  else
    {
      label: check.name,
      count: total_count,
      link: "#{ENV["website_url"]}/projects/#{@project.to_param}/sheets?search=checks:#{check.to_param}"
    }
  end
end

check_hashes.reject! { |hash| hash[:count].zero? }
check_hashes.sort_by! { |hash| -hash[:count] }

if check_hashes.blank?
  check_hashes = [
    {
      label: "Failing checks",
      count: 0,
      sites: sites.collect { |site| { site_id: site.id, count: 0 } }
    }
  ]
end

json.rows check_hashes
