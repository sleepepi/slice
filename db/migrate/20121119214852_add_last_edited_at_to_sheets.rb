class AddLastEditedAtToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :last_edited_at, :datetime
  end
end
