class AddResponseCountToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :response_count, :integer
    add_column :sheets, :total_response_count, :integer
  end
end
