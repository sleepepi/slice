# frozen_string_literal: true

CarrierWave.configure do |config|
  config.root = if Rails.env.test?
                  Rails.root.join("test", "support")
                else
                  Rails.root.join("carrierwave")
                end
end
