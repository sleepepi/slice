# frozen_string_literal: true

# Allows main sections, subsections, and warnings to be added to designs.
class Section < ApplicationRecord
  # Callbacks
  after_save :check_for_changes_affecting_cached_pdfs

  # Constants
  LEVELS = [
    ["Section", 0],
    ["Subsection", 1],
    ["Informational", 2],
    ["Warning", 3],
    ["Alert", 4]
  ]

  # Concerns
  include Latexable

  include Strippable
  strip :name, :description

  include Translatable
  translates :name, :description

  # Uploaders
  mount_uploader :image, ImageUploader

  # Relationships
  belongs_to :project
  belongs_to :design
  belongs_to :user

  # Methods

  def to_slug
    name.to_s.parameterize
  end

  def level_name
    LEVELS.find { |_name, value| value == level }&.first || "Section"
  end

  def display_on_report?
    level.in?(0..1)
  end

  # Check if keys changed that affect the design's cached PDFs
  def check_for_changes_affecting_cached_pdfs
    overlap = %w(name description level) & previous_changes.keys
    return if overlap.empty?

    design.touch :pdf_cache_busted_at
  end

  def update_or_translate(params)
    params = save_translation!(params) if World.translate_language?
    update(params)
  end

  def save_translation!(params)
    self.class.translatable_attributes.each do |key|
      params = save_key_translation_if_present(params, key)
    end
    params
  end

  def save_key_translation_if_present(params, key)
    return params unless params.key?(key)

    save_object_translation!(self, key, params.delete(key))
    params
  end

  def description_with_images
    description.to_s.gsub(/\{img\:(\d+)\}/) do
      image = design.design_images.find_by(id: $1)
      if image
        url = "#{ENV["website_url"]}/projects/#{project.to_param}/designs/#{design.to_param}/images/#{image.id}"
        "![](#{url})"
      else
        $1
      end
    end
  end

  def description_for_latex
    latex_safe(description).to_s.gsub(/\\textbackslash\{\}\{img\:(\d+)\\textbackslash\{\}\}/) do
      image = design.design_images.find_by(id: $1)
      if image
        <<~LATEX
          \\begin{figure}[!htpb]
            \\includegraphics[max width=7.5in]{#{image.file.path}}
          \\end{figure}
        LATEX
      else
        $1
      end
    end
  end
end
