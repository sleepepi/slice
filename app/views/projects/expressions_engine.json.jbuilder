# frozen_string_literal: true

json.expressions params[:expressions]

json.tokens do
  json.array! @engine.lexer.tokens, :token_type, :raw, :auto
end

json.subjects_count number_with_delimiter(@engine.interpreter.subjects_count)

json.run_ms @engine.run_ms


json.sobjects do
  json.array! @engine.interpreter.sobjects.first(10).collect { |key, sobject| sobject }, :subject_id, :values
end
