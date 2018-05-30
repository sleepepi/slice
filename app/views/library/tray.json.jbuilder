json.prettify!
json.partial! "trays/pretty", tray: @tray

json.cubes do
  json.array!(@tray.cubes) do |cube|
    json.partial! "cubes/pretty", cube: cube
  end
end
