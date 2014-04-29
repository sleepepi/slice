require 'valuables/default'

module Valuables

  class MultipleResponse < Default

    def name
      @object.variable.shared_options_select_values(@object.responses.pluck(:value)).collect{|option| option[:value] + ": " + option[:name]}
    end

    def raw
      @object.variable.shared_options_select_values(@object.responses.pluck(:value)).collect{|option| option[:value]}
    end

  end

end
