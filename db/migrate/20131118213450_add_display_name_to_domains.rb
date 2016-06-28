class AddDisplayNameToDomains < ActiveRecord::Migration[4.2]
  def up
    add_column :domains, :display_name, :string
    Domain.all.each do |domain|
      domain.update_column :display_name, domain.name
    end
  end

  def down
    remove_column :domains, :display_name
  end
end
