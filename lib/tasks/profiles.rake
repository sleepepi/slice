# frozen_string_literal: true

# TODO: Remove in v64
namespace :profiles do
  desc "Migrate existing gravatars to profile."
  task migrate_gravatars: :environment do
    user_count = User.count
    User.order(:id).each_with_index do |user, index|
      print "\rMigrating gravatar for User #{user.id} (#{((index + 1) * 100.0 / user_count).round(1)}%)"
      gravatar_id = Digest::MD5.hexdigest(user.email.to_s.downcase)
      size = 360
      user.update(remote_profile_picture_url: "http://gravatar.com/avatar/#{gravatar_id}?&s=#{size}&d=404")
    end
    puts ""
  end
end
# END TODO
