# frozen_string_literal: true

# Stores a value for a single variable on a sheet.
class SheetVariable < ApplicationRecord
  # Uploaders
  mount_uploader :response_file, GenericUploader

  # Concerns
  include Formattable
  include Valuable

  # Scopes
  def self.with_files
    joins(variable: :design_options)
      .where(variables: { variable_type: "file" })
      .where.not(response_file: [nil, ""])
  end

  # Validations
  validates :sheet_id, presence: true

  # Relationships
  belongs_to :sheet, touch: true
  belongs_to :user, optional: true
  belongs_to :domain_option, optional: true
  has_many :grids

  def self.not_empty
    where.not(id: all_empty.select(:id))
  end

  def self.all_empty
    where(response_file: [nil, ""], value: [nil, ""], domain_option_id: nil)
      .where(id: grids_empty.select(:id))
      .where(id: responses_empty.select(:id))
  end

  def self.grids_empty
    left_outer_joins(:grids).having("COUNT(grids) = 0").group(:id)
  end

  def self.responses_empty
    left_outer_joins(:responses).having("COUNT(responses) = 0").group(:id)
  end
end
