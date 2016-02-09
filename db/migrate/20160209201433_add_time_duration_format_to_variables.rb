class AddTimeDurationFormatToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :time_duration_format, :string
  end
end
