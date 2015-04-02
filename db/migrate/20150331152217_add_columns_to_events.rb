class AddColumnsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :archived, :boolean, null: false, default: false
    add_column :events, :position, :integer
    add_column :events, :scheduled, :boolean, null: false, default: true
    add_column :events, :slug, :string
  end
end
