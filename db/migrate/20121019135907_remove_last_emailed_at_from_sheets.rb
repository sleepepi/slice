class RemoveLastEmailedAtFromSheets < ActiveRecord::Migration
  def up
    remove_column :sheets, :last_emailed_at
  end

  def down
    add_column :sheets, :last_emailed_at, :datetime
  end
end
