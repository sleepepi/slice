# frozen_string_literal: true

module Formatters
  # Used to help format arrays of database responses for variables with domains
  class DomainFormatter < DefaultFormatter
    def name_responses
      shared_responses = shared_options
      @responses.collect { |r| name_response(r, shared_responses) }
    end

    def shared_options
      @variable.shared_options
    end

    def name_response(response, shared_responses = shared_options)
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
      hash = shared_responses.find { |o| o[:value] == response }
      [hash[:value], hash[:name]].compact.join(': ') if hash
    end
  end
end
