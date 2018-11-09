class ChangeDesignIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :designs, :id, :bigint

    change_column :design_options, :design_id, :bigint
    change_column :design_prints, :design_id, :bigint
    change_column :event_designs, :design_id, :bigint
    change_column :sections, :design_id, :bigint
    change_column :sheets, :design_id, :bigint
  end

  def down
    change_column :designs, :id, :integer

    change_column :design_options, :design_id, :integer
    change_column :design_prints, :design_id, :integer
    change_column :event_designs, :design_id, :integer
    change_column :sections, :design_id, :integer
    change_column :sheets, :design_id, :integer
  end
end
