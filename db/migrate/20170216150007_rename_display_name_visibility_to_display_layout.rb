class RenameDisplayNameVisibilityToDisplayLayout < ActiveRecord::Migration[5.0]
  def change
    rename_column :variables, :display_name_visibility, :display_layout
  end
end
