json.array!(@randomizations) do |randomization|
  json.extract! randomization, :id, :project_id, :randomization_scheme_id, :user_id, :list_id, :block_group, :multiplier, :position, :treatment_arm_id, :subject_id, :randomized_at, :randomized_by_id, :attested, :deleted
  json.url randomization_url(randomization, format: :json)
end
