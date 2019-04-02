# frozen_string_literal: true

# Represents a (cached) PDF for a design by language. DesignPrints can be marked
# as outdated in order to generate a new PDF.
class DesignPrint < ApplicationRecord
  # Uploaders
  mount_uploader :file, DesignPdfUploader

  # Concerns
  include Latexable

  # Validations
  validates :language,
            presence: true,
            inclusion: { in: World.available_languages.collect(&:code).map(&:to_s) },
            uniqueness: { scope: :design_id }
  validates :file_size, numericality: { greater_than_or_equal_to: 0 }

  # Relationships
  belongs_to :design

  # Methods

  # Get latex partial location.
  def latex_partial(partial)
    File.read(File.join("app", "views", "designs", "latex", "_#{partial}.tex.erb"))
  end

  # TODO: "1 hour old" designs shouldn't need to be regenerated, instead
  # changes to design should require a design PDF to be regenerated:
  # - [ ] DesignOption.updated_at (on design)
  # - [ ] Variable.updated_at (on design)
  # - [ ] Section.updated_at (on design)
  # - [ ] Domain.updated_at (on design)
  # - [ ] Domain.updated_at (on design)
  # - [ ] DomainOption.updated_at (on design)
  # The following also invalidate cached design PDFs
  # - [ ] projects.hide_values_on_pdfs
  # - [ ] projects.name
  # - [ ] sites.name
  # - [ ] subjects.code
  # - [ ] events.name
  def regenerate?
    outdated? ||
      updated_at < design.updated_at ||
      updated_at < design.project.updated_at ||
      updated_at < Time.zone.today - 1.hour
  end

  def regenerate!
    jobname = "design_#{design_id}_#{language}"
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
    @design = design # Needed by Binding
    File.open(temp_tex, "w") do |file|
      file.syswrite(ERB.new(latex_partial("print")).result(binding))
    end
  end
end
