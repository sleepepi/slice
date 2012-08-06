class AddUpdaterIdToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :updater_id, :integer
  end
end
