class AddLastEmailedAtToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :last_emailed_at, :datetime
  end
end
