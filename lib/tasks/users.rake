# frozen_string_literal: true

# TODO: Remove in v60.0.0

namespace :users do
  desc "Merge first name and last name into full name"
  task migrate_full_name: :environment do
    User.find_each do |user|
      user.update(full_name: "#{user.first_name} #{user.last_name}")
    end
  end
end
