class AddSoundEnabledToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :sound_enabled, :boolean, null: false, default: false
  end
end
