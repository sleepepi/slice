# frozen_string_literal: true

class Tray < ApplicationRecord
  # Concerns
  include Latexable
  include Searchable
  include Sluggable
  include Strippable
  strip :name

  # Validations
  validates :name, presence: true
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ },
                   exclusion: { in: %w(new edit create update destroy trays) },
                   uniqueness: { scope: :profile_id },
                   allow_nil: true
  validates :time_in_seconds, numericality: { greater_than_or_equal_to: 0 }

  # Relationships
  belongs_to :profile
  # has_many :cubes, -> { order(:position) }

  # Methods
  def self.searchable_attributes
    %w(name description)
  end

  def public?
    true
  end

  def latex_partial(partial)
    File.read(File.join("app", "views", "trays", "latex", "_#{partial}.tex.erb"))
  end

  def latex_file_location
    jobname = "tray_#{id}"
    output_folder = File.join("tmp", "files", "tex")
    file_tex = File.join("tmp", "files", "tex", "#{jobname}.tex")

    File.open(file_tex, "w") do |file|
      file.syswrite(ERB.new(latex_partial("print")).result(binding))
    end

    Design.generate_pdf(jobname, output_folder, file_tex)
  end
end
