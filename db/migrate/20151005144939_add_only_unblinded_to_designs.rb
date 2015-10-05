class AddOnlyUnblindedToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :only_unblinded, :boolean, null: false, default: false
  end
end
