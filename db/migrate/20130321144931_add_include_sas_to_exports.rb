class AddIncludeSasToExports < ActiveRecord::Migration
  def change
    add_column :exports, :include_sas, :boolean, null: false, default: false
  end
end
