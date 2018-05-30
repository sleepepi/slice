json.url tray_url(tray.profile, tray, format: :json)
json.profile tray.profile.username
json.extract! tray, :slug, :name #, :created_at, :updated_at
