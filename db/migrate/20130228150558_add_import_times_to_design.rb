class AddImportTimesToDesign < ActiveRecord::Migration
  def change
    add_column :designs, :import_started_at, :datetime
    add_column :designs, :import_ended_at, :datetime
  end
end
