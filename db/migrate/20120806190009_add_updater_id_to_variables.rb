class AddUpdaterIdToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :updater_id, :integer
  end
end
