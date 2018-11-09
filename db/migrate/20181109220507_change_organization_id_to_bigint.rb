class ChangeOrganizationIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :organization_users, :organization_id, :bigint
    change_column :profiles, :organization_id, :bigint
  end

  def down
    change_column :organization_users, :organization_id, :integer
    change_column :profiles, :organization_id, :integer
  end
end
