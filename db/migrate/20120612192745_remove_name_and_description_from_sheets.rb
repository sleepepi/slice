class RemoveNameAndDescriptionFromSheets < ActiveRecord::Migration
  def up
    remove_column :sheets, :name
    remove_column :sheets, :description
  end

  def down
    add_column :sheets, :name, :string
    add_column :sheets, :description, :text
  end
end
