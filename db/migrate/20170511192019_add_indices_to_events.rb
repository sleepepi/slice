class AddIndicesToEvents < ActiveRecord::Migration[5.0]
  def change
    add_index :events, :project_id
    add_index :events, :user_id
    add_index :events, :archived
    add_index :events, :position
    add_index :events, :only_unblinded
  end
end
