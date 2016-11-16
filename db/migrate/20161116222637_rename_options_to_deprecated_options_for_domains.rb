class RenameOptionsToDeprecatedOptionsForDomains < ActiveRecord::Migration[5.0]
  def change
    rename_column :domains, :options, :deprecated_options
  end
end
