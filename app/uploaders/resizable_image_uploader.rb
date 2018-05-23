# frozen_string_literal: true

# Resizes uploaded images to preset dimensions
class ResizableImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    File.join(model.class.to_s.underscore.pluralize, model.id.to_s, mounted_as.to_s)
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  process resize_to_limit: [1140, 1140]

  # Create different versions of your uploaded files:
  version :preview do
    process resize_to_fill: [360, 360]
  end

  version :thumb do
    process resize_to_fill: [128, 128]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "image#{File.extname(original_filename)}" if original_filename
  end
end
