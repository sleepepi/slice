class AddPathwaysCountToAeTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :ae_teams, :pathways_count, :integer, null: false, default: 0
    add_index :ae_teams, :pathways_count
  end
end
