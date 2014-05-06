require 'valuables/default'

module Valuables

  class MultipleResponse < Default

    def name
      response_options.collect{|option| option[:value] + ": " + option[:name]}
    end

    def raw
      response_options.collect{|option| option[:value]}
    end

    def display_name
      response_options.collect{|option| option[:name]}
    end

    private

    def response_options
      @object.variable.shared_options_select_values(@object.responses.pluck(:value))
    end

  end

end
