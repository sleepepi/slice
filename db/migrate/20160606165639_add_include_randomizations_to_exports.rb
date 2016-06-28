class AddIncludeRandomizationsToExports < ActiveRecord::Migration[4.2]
  def change
    add_column :exports, :include_randomizations, :boolean, null: false, default: false
  end
end
