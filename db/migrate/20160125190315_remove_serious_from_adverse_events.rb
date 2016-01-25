class RemoveSeriousFromAdverseEvents < ActiveRecord::Migration
  def change
    remove_column :adverse_events, :serious, :boolean
  end
end
