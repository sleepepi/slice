json.array!(@treatment_arms) do |treatment_arm|
  json.extract! treatment_arm, :id, :name, :project_id, :randomization_scheme_id, :allocation, :user_id, :deleted
  json.url treatment_arm_url(treatment_arm, format: :json)
end
