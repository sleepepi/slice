namespace :users do

  desc "Migrate email settings"
  task update_email_settings: :environment do
    User.all.each do |user|
      user.update_column :emails_enabled, user.email_on?(:send_email)
    end
  end

end
