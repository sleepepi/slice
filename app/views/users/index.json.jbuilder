# frozen_string_literal: true

json.array!(params[:q].to_s.split(',')) do |term|
  if term.strip.casecmp('me') == 0
    json.name current_user.name
    json.id current_user.name
  else
    json.name term.strip.titleize
    json.id term.strip.titleize
  end
end

json.array!(@users) do |user|
  json.name user.name
  json.id user.name
end
