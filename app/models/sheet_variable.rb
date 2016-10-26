# frozen_string_literal: true

class SheetVariable < ApplicationRecord
  # Concerns
  include Formattable, Valuable

  # Scopes
  scope :with_files, -> { joins(variable: :design_options).where(variables: { variable_type: 'file' }).where.not(response_file: [nil, '']) }

  # Model Validation
  validates :sheet_id, presence: true

  # Model Relationships
  belongs_to :sheet, touch: true
  belongs_to :user
  has_many :grids

  # Returns its ID if it's not empty, else nil
  def empty_or_not
    id if responses.count > 0 || grids.count > 0 || !response.blank? || !response_file.blank?
  end
end
