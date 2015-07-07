json.array!(@block_size_multipliers) do |block_size_multiplier|
  json.extract! block_size_multiplier, :id, :project_id, :randomization_scheme_id, :value, :allocation, :deleted
  json.url block_size_multiplier_url(block_size_multiplier, format: :json)
end
