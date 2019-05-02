# frozen_string_literal: true

case Rails.env
when "production"
  if ENV["AMAZON"].to_s == "true"
    CarrierWave.configure do |config|
      config.fog_provider = "fog/aws"                        # required
      config.fog_credentials = {
        provider:              "AWS",                        # required
        aws_access_key_id:     Rails.application.credentials.dig(:aws, :access_key_id),
        aws_secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
        region:                Rails.application.credentials.dig(:aws, :region)
        # host:                  "s3.example.com",             # optional, defaults to nil
        # endpoint:              'https://s3.example.com:8080' # optional, defaults to nil
      }
      config.fog_directory  = Rails.application.credentials.dig(:aws, :bucket)
      config.fog_public     = false # Optional, default is true
      # config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" } # Optional, default is {}
      config.storage = :fog
    end
  else
    CarrierWave.configure do |config|
      config.root = Rails.root.join("carrierwave")
    end
  end
when "development"
  CarrierWave.configure do |config|
    config.root = Rails.root.join("storage", "carrierwave")
  end
else # when "test"
  CarrierWave.configure do |config|
    config.root = Rails.root.join("test", "storage", "carrierwave")
    config.enable_processing = false
  end
end
