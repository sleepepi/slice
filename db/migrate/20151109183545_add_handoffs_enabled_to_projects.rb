class AddHandoffsEnabledToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :handoffs_enabled, :boolean, null: false, default: false
  end
end
