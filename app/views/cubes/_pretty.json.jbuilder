# frozen_string_literal: true

json.extract! cube, :position, :text, :description, :cube_type #, :created_at, :updated_at

if cube.faces.present?
  json.faces do
    json.array!(cube.faces) do |face|
      json.partial! "faces/pretty", face: face
    end
  end
end
