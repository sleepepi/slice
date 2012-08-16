class AddLastEmailedAtToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :last_emailed_at, :datetime
  end
end
