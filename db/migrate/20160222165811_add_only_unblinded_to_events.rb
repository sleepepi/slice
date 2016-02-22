class AddOnlyUnblindedToEvents < ActiveRecord::Migration
  def change
    add_column :events, :only_unblinded, :boolean, null: false, default: false
  end
end
