# frozen_string_literal: true

namespace :invites do
  desc "Clear deprecated invites."
  task clear: :environment do
    ProjectUser.where(user_id: nil).destroy_all
    SiteUser.where(user_id: nil).destroy_all
  end
end
