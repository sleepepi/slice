json.array!(@stratification_factors) do |stratification_factor|
  json.extract! stratification_factor, :id, :project_id, :randomization_scheme_id, :name, :deleted
  json.url stratification_factor_url(stratification_factor, format: :json)
end
