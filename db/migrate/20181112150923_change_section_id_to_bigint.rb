class ChangeSectionIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :sections, :id, :bigint

    change_column :design_options, :section_id, :bigint
  end

  def down
    change_column :sections, :id, :integer

    change_column :design_options, :section_id, :integer
  end
end
