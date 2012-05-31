class AddSiteIdToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :site_id, :integer
  end
end
