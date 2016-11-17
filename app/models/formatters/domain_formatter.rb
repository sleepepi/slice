# frozen_string_literal: true

module Formatters
  # Used to help format arrays of database responses for variables with domains.
  class DomainFormatter < DefaultFormatter
    def name_responses
      shared_responses = domain_options
      @responses.collect { |r| name_response(r, shared_responses) }
    end

    def domain_options
      @variable.domain_options
    end

    def name_response(response, shared_responses = domain_options)
      domain_string = hash_value_and_name(response, shared_responses)
      if domain_string.blank?
        components(response).compact.join(' ').squish if response.present?
      else
        domain_string
      end
    end

    def components(response)
      [@variable.prepend, raw_response(response), @variable.units, @variable.append]
    end

    def hash_value_and_name(response, shared_responses)
      domain_option = shared_responses.find_by(value: response)
      domain_option.value_and_name if domain_option
    end
  end
end
