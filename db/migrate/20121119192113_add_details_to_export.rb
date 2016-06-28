class AddDetailsToExport < ActiveRecord::Migration[4.2]
  def change
    add_column :exports, :details, :text
  end
end
