class AddShortNameToAeTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :ae_review_teams, :short_name, :string
  end
end
