# frozen_string_literal: true

module DoubleDataEntry
  extend ActiveSupport::Concern

  included do
    scope :original_entry, -> { where verifying_sheet_id: nil }
    scope :double_data_entry_exists, -> { where('sheets.id IN (select sheets.verifying_sheet_id from sheets where sheets.verifying_sheet_id IS NOT NULL and sheets.deleted = ?)', false) }
    scope :double_data_entry_does_not_exist, -> { where('sheets.id NOT IN (select sheets.verifying_sheet_id from sheets where sheets.verifying_sheet_id IS NOT NULL and sheets.deleted = ?)', false) }

    belongs_to :verifying_sheet, class_name: 'Sheet'
    has_many :verification_sheets, -> { where(deleted: false).order(:id) }, foreign_key: 'verifying_sheet_id', class_name: 'Sheet'
  end

  def shared_verification_params
    attributes.select { |key, val| %w(design_id project_id subject_id user_id subject_event_id verifying_sheet_id).include?(key.to_s) }.merge({ verifying_sheet_id: id })
  end

  def not_double_data_entry?
    verifying_sheet.blank?
  end

  def double_data_entry?
    !self.not_double_data_entry?
  end
end
