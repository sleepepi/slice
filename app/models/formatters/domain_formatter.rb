# frozen_string_literal: true

module Formatters
  # Used to help format arrays of database responses for variables with domains.
  class DomainFormatter < DefaultFormatter
    # TODO: Change this to iterate through each domain option and apply the
    # changes to the array in batch instead of one by one.
    def name_responses
      shared_responses = domain_options
      @responses.collect { |r| name_response(r, shared_responses) }
    end

    def raw_responses
      shared_responses = domain_options
      @responses.collect { |r| raw_response(r, shared_responses) }
    end

    def domain_options
      @variable.domain_options
    end

    def name_response(response, shared_responses = domain_options)
      domain_string = hash_value_and_name(response, shared_responses)
      if domain_string.blank?
        components(response).compact.join(" ").squish if response.present?
      else
        domain_string
      end
    end

    def raw_response(response, shared_responses = domain_options)
      domain_option = shared_responses.find { |option| option.value == response }
      if domain_option
        domain_option.value
      else
        response
      end
    end

    def components(response)
      [@variable.prepend, formatted(response), @variable.units, @variable.append]
    end

    def formatted(response)
      raw_response(response)
    end

    def hash_value_and_name(response, shared_responses)
      domain_option = shared_responses.find { |option| option.value == response }
      domain_option.value_and_name if domain_option
    end
  end
end
