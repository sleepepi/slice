class AddDossierToAeAdverseEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :ae_adverse_events, :dossier, :string
    add_column :ae_adverse_events, :dossier_content_type, :string
    add_column :ae_adverse_events, :dossier_byte_size, :bigint, null: false, default: 0
    add_column :ae_adverse_events, :outdated, :boolean, null: false, default: true

    add_index :ae_adverse_events, :dossier_content_type
    add_index :ae_adverse_events, :dossier_byte_size
  end
end
