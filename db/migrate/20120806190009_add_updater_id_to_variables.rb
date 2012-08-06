class AddUpdaterIdToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :updater_id, :integer
  end
end
