class AddSuccessfullyValidatedToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :successfully_validated, :boolean
  end
end
