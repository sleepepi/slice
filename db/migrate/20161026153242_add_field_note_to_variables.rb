class AddFieldNoteToVariables < ActiveRecord::Migration[5.0]
  def change
    add_column :variables, :field_note, :string
  end
end
