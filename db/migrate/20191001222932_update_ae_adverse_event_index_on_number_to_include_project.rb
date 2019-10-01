class UpdateAeAdverseEventIndexOnNumberToIncludeProject < ActiveRecord::Migration[6.0]
  def up
    remove_index :ae_adverse_events, :number
    add_index :ae_adverse_events, [:project_id, :number], unique: true
  end

  def down
    remove_index :ae_adverse_events, [:project_id, :number]
    add_index :ae_adverse_events, :number, unique: true
  end
end
