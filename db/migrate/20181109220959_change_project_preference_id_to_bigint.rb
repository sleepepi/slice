class ChangeProjectPreferenceIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :project_preferences, :id, :bigint
  end

  def down
    change_column :project_preferences, :id, :integer
  end
end
