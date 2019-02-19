class CreateProjectLanguages < ActiveRecord::Migration[6.0]
  def change
    create_table :project_languages do |t|
      t.bigint :project_id
      t.string :language_code
      t.timestamps

      t.index [:project_id, :language_code], unique: true
    end
  end
end
