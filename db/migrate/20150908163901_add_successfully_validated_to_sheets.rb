class AddSuccessfullyValidatedToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :successfully_validated, :boolean
  end
end
