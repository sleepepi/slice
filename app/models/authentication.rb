class Authentication < ActiveRecord::Base
  attr_accessible :provider, :uid, :user_id

  belongs_to :user

  def provider_name
    OmniAuth.config.camelizations[provider.to_s.downcase] || provider.to_s.titleize
  end
end
