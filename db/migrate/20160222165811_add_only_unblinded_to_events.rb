class AddOnlyUnblindedToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :only_unblinded, :boolean, null: false, default: false
  end
end
