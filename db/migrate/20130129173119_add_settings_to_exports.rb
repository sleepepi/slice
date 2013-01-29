class AddSettingsToExports < ActiveRecord::Migration
  def change
    add_column :exports, :include_xls, :boolean, null: false, default: false
    add_column :exports, :include_csv_labeled, :boolean, null: false, default: false
    add_column :exports, :include_csv_raw, :boolean, null: false, default: false
    add_column :exports, :include_pdf, :boolean, null: false, default: false
    add_column :exports, :include_data_dictionary, :boolean, null: false, default: false
  end
end
