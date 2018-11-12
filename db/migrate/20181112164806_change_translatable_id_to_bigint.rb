class ChangeTranslatableIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :translations, :translatable_id, :bigint
  end

  def down
    change_column :translations, :translatable_id, :integer
  end
end
