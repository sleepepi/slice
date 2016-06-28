class RemoveExportTypeFromExports < ActiveRecord::Migration[4.2]
  def up
    remove_column :exports, :export_type
  end

  def down
    add_column :exports, :export_type, :string, null: false, default: 'sheets'
  end
end
