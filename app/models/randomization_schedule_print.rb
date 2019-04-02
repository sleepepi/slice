# frozen_string_literal: true

# Represents a (cached) PDF for a randomization schedule by language.
# RandomizationSchedulePrints can be marked as outdated in order to generate a
# new PDF.
class RandomizationSchedulePrint < ApplicationRecord
  # Uploaders
  mount_uploader :file, RandomizationSchedulePdfUploader

  # Concerns
  include Latexable

  # Validations
  validates :language,
            presence: true,
            inclusion: { in: World.available_languages.collect(&:code).map(&:to_s) },
            uniqueness: { scope: :randomization_id }
  validates :file_size, numericality: { greater_than_or_equal_to: 0 }

  # Relationships
  belongs_to :randomization

  # Methods

  # Get latex partial location.
  def latex_partial(partial)
    File.read(File.join("app", "views", "randomizations", "latex", "_#{partial}.tex.erb"))
  end

  def regenerate?
    outdated? || updated_at < Time.zone.today - 1.hour
  end

  def regenerate!
    jobname = "randomization_#{randomization_id}_schedule_#{language}"
    temp_dir = Dir.mktmpdir
    temp_tex = File.join(temp_dir, "#{jobname}.tex")
    write_tex_file(temp_tex)
    self.class.compile(jobname, temp_dir, temp_tex)
    temp_pdf = File.join(temp_dir, "#{jobname}.pdf")
    update outdated: false, file: File.open(temp_pdf, "r"), file_size: File.size(temp_pdf) if File.exist?(temp_pdf)
  ensure
    # Remove the directory.
    FileUtils.remove_entry temp_dir
  end

  def write_tex_file(temp_tex)
    @randomization = randomization # Needed by Binding
    File.open(temp_tex, "w") do |file|
      file.syswrite(ERB.new(latex_partial("schedule")).result(binding))
    end
  end
end
