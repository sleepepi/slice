class SheetTransactionAudit < ActiveRecord::Base

  # Model Relationships
  belongs_to :sheet_transaction
  belongs_to :user
  belongs_to :sheet
  belongs_to :sheet_variable
  belongs_to :grid

end
