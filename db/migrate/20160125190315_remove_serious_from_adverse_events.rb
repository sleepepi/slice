class RemoveSeriousFromAdverseEvents < ActiveRecord::Migration[4.2]
  def change
    remove_column :adverse_events, :serious, :boolean
  end
end
