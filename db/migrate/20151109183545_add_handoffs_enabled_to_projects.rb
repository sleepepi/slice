class AddHandoffsEnabledToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :handoffs_enabled, :boolean, null: false, default: false
  end
end
