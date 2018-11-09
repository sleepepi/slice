class ChangeListIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :lists, :id, :bigint

    change_column :list_options, :list_id, :bigint
    change_column :randomization_characteristics, :list_id, :bigint
    change_column :randomizations, :list_id, :bigint
  end

  def down
    change_column :lists, :id, :integer

    change_column :list_options, :list_id, :integer
    change_column :randomization_characteristics, :list_id, :integer
    change_column :randomizations, :list_id, :integer
  end
end
