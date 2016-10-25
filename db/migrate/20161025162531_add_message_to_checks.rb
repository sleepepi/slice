class AddMessageToChecks < ActiveRecord::Migration[5.0]
  def change
    add_column :checks, :message, :string
  end
end
