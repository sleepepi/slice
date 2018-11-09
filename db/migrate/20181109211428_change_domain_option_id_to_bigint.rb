class ChangeDomainOptionIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :domain_options, :id, :bigint

    change_column :grids, :domain_option_id, :bigint
    change_column :responses, :domain_option_id, :bigint
    change_column :sheet_variables, :domain_option_id, :bigint
  end

  def down
    change_column :domain_options, :id, :integer

    change_column :grids, :domain_option_id, :integer
    change_column :responses, :domain_option_id, :integer
    change_column :sheet_variables, :domain_option_id, :integer
  end
end
