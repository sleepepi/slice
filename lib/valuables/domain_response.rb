# frozen_string_literal: true

require 'valuables/default'

module Valuables
  class DomainResponse < Default
    protected

    def hash
      (@object.variable.shared_options_select_values([@object.response]).first || {})
    end

    def hash_value_and_name
      [hash[:value], hash[:name]].compact.join(': ')
    end

    def hash_display_name
      hash[:name].to_s
    end
  end
end
