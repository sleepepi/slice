CarrierWave.configure do |config|
  config.root = if Rails.env.test?
    File.join( Rails.root, 'test', 'support' )
  else
    File.join( Rails.root, 'carrierwave' )
  end
end
