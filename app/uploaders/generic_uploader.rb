# frozen_string_literal: true

# Allows generic files to be attached to a record.
class GenericUploader < CarrierWave::Uploader::Base
  # Choose what kind of storage to use for this uploader:
  storage ENV["AMAZON"].to_s == "true" ? :fog : :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  # TODO: Remove in v75
  def former_store_dir
    File.join(model.class.to_s.underscore.pluralize, model.id.to_s, mounted_as.to_s)
  end
  # END TODO: Remove in v75

  def store_dir
    File.join(
      "projects",
      model.project_id.to_s,
      model.class.to_s.underscore.pluralize,
      model.id.to_s
    )
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/assets/fallback/" + [version_name, "default.png"].compact.join("_")
  # end

  # # Add a list of extensions which are allowed to be uploaded.
  # def extension_allowlist
  #   %w(jpg jpeg gif png doc docx pdf xls xlsx rtf)
  # end

  # Override the filename of the uploaded files:
  # def filename
  #   "something.jpg" if original_filename
  # end
end
