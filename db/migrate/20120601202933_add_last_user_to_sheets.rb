class AddLastUserToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :last_user_id, :integer
  end
end
