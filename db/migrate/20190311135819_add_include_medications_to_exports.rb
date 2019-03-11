class AddIncludeMedicationsToExports < ActiveRecord::Migration[6.0]
  def change
    add_column :exports, :include_medications, :boolean, null: false, default: false
  end
end
