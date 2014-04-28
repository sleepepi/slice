json.extract! design, :name, :description

json.options do
  json.array!(design.options) do |option|
    json.partial! 'designs/option', option: option
  end
end
