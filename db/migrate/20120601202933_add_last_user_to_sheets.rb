class AddLastUserToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :last_user_id, :integer
  end
end
