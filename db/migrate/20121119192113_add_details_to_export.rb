class AddDetailsToExport < ActiveRecord::Migration
  def change
    add_column :exports, :details, :text
  end
end
