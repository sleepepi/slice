class AddSubjectCodeFormatToSites < ActiveRecord::Migration[4.2]
  def change
    add_column :sites, :subject_code_format, :string
  end
end
