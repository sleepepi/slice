class ChangeSiteIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :sites, :id, :bigint

    change_column :domain_options, :site_id, :bigint
    change_column :expected_randomizations, :site_id, :bigint
    change_column :randomization_characteristics, :site_id, :bigint
    change_column :site_users, :site_id, :bigint
    change_column :subjects, :site_id, :bigint
  end

  def down
    change_column :sites, :id, :integer

    change_column :domain_options, :site_id, :integer
    change_column :expected_randomizations, :site_id, :integer
    change_column :randomization_characteristics, :site_id, :integer
    change_column :site_users, :site_id, :integer
    change_column :subjects, :site_id, :integer
  end
end
