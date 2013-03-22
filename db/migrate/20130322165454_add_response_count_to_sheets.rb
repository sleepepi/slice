class AddResponseCountToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :response_count, :integer
    add_column :sheets, :total_response_count, :integer
  end
end
