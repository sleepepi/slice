class AddIncludeSasToExports < ActiveRecord::Migration[4.2]
  def change
    add_column :exports, :include_sas, :boolean, null: false, default: false
  end
end
