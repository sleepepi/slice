class AddReportedAtToAeAdverseEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :ae_adverse_events, :reported_at, :datetime
  end
end
