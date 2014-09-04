class AddIncludeRToExports < ActiveRecord::Migration
  def change
    add_column :exports, :include_r, :boolean, null: false, default: false
  end
end
