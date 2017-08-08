# frozen_string_literal: true

json.extract!(sheet_variable, :variable_id, :sheet_id, :value, :response_file, :domain_option_id)
json.response sheet_variable.get_response(:raw)
json.value sheet_variable.variable.response_to_value(sheet_variable.get_response(:raw))
