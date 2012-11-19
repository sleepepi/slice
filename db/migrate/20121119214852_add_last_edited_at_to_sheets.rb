class AddLastEditedAtToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :last_edited_at, :datetime
  end
end
