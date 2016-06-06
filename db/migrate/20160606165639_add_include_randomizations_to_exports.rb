class AddIncludeRandomizationsToExports < ActiveRecord::Migration
  def change
    add_column :exports, :include_randomizations, :boolean, null: false, default: false
  end
end
