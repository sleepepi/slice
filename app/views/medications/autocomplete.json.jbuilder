# frozen_string_literal: true

@values = @medication_variable&.autocomplete_values_array || []
@values.reject! { |value| (/#{Regexp.escape(params[:search])}/i =~ value).nil? }

json.array! @values
