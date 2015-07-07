json.array!(@stratification_factor_options) do |stratification_factor_option|
  json.extract! stratification_factor_option, :id, :project_id, :randomization_scheme_id, :stratification_factor_id, :user_id, :label, :value, :deleted
  json.url stratification_factor_option_url(stratification_factor_option, format: :json)
end
