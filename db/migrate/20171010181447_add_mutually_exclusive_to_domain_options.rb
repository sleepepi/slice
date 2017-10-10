class AddMutuallyExclusiveToDomainOptions < ActiveRecord::Migration[5.1]
  def change
    add_column :domain_options, :mutually_exclusive, :boolean, null: false, default: false
  end
end
