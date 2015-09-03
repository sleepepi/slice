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
      # Collect is used here since responses may be "built" and not yet saved to database
      @object.variable.shared_options_select_values(@object.responses.collect(&:value))
    end

  end

end
