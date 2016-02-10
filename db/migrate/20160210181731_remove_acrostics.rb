class RemoveAcrostics < ActiveRecord::Migration
  def change
    remove_column :subjects, :acrostic, :string, null: false, default: ''
    remove_column :projects, :acrostic_enabled, :boolean, null: false, default: false
  end
end
