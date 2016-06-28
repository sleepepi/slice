class AddImportTimesToDesign < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :import_started_at, :datetime
    add_column :designs, :import_ended_at, :datetime
  end
end
