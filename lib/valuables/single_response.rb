# frozen_string_literal: true

require 'valuables/domain_response'

module Valuables
  class SingleResponse < DomainResponse

    def name
      hash_value_and_name
    end

    def display_name
      hash_display_name
    end
  end
end
