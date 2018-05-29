class AddKeywordsToTrays < ActiveRecord::Migration[5.2]
  def change
    add_column :trays, :keywords, :string
  end
end
