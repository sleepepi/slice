class ChangeDomainIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :domains, :id, :bigint

    change_column :domain_options, :domain_id, :bigint
    change_column :variables, :domain_id, :bigint
  end

  def down
    change_column :domains, :id, :integer

    change_column :domain_options, :domain_id, :integer
    change_column :variables, :domain_id, :integer
  end
end
