class RemoveDeprecatedOptionsFromDomains < ActiveRecord::Migration[5.0]
  def change
    remove_column :domains, :deprecated_options, :text
  end
end
