class RemoveViewedFromExports < ActiveRecord::Migration[5.2]
  def change
    remove_column :exports, :viewed, :boolean, null: false, default: false
  end
end
