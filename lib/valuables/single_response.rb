require 'valuables/domain_response'

module Valuables

  class SingleResponse < DomainResponse

    def name
      hash_value_and_name
    end

    def raw
      begin Integer(@object.response) end rescue @object.response
    end

  end

end
