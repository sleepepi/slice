# frozen_string_literal: true

# Allows images to be attached to design sections and descriptions.
class DesignImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage ENV["AMAZON"].to_s == "true" ? :fog : :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    File.join(
      "projects",
      model.project_id.to_s,
      "designs",
      model.design_id.to_s,
      "images",
      model.id.to_s
    )
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/assets/fallback/" + [version_name, "default.png"].compact.join("_")
  # end

  # Process files as they are uploaded:
  process resize_to_limit: [1600, 1200]

  # Add a list of extensions which are allowed to be uploaded.
  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  def filename
    "image#{File.extname(original_filename)}" if original_filename
  end
end
