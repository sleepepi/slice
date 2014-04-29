require 'valuables/default'

module Valuables

  class DomainResponse < Default

    protected

    def hash_value_and_name
      hash = (@object.variable.shared_options_select_values([@object.response]).first || {})
      [hash[:value], hash[:name]].compact.join(': ')
    end

  end

end
