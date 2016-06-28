class AddTimeDurationFormatToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :time_duration_format, :string
  end
end
