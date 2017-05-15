class ChangeTimeDurationFormatDefaults < ActiveRecord::Migration[5.0]
  def up
    change_column :variables, :time_duration_format, :string, null: false, default: 'hh:mm:ss'
  end

  def down
    change_column :variables, :time_duration_format, :string, null: true, default: nil
  end
end
