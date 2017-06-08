# frozen_string_literal: true

# Tracks an individual change to a sheet.
class SheetTransactionAudit < ApplicationRecord
  # Relationships
  belongs_to :sheet
  belongs_to :sheet_transaction
  belongs_to :user, optional: true
  belongs_to :sheet_variable, optional: true
  belongs_to :grid, optional: true
end
