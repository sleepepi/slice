class AddIncludeRToExports < ActiveRecord::Migration[4.2]
  def change
    add_column :exports, :include_r, :boolean, null: false, default: false
  end
end
