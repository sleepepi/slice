# frozen_string_literal: true

class SheetTransactionAudit < ApplicationRecord
  # Relationships
  belongs_to :sheet_transaction
  belongs_to :user
  belongs_to :sheet
  belongs_to :sheet_variable
  belongs_to :grid
end
