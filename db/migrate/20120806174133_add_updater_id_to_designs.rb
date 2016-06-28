class AddUpdaterIdToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :updater_id, :integer
  end
end
