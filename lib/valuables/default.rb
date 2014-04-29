module Valuables

  class Default

    attr_reader :object

    def initialize(object)
      @object = object
    end

    def name
      @object.response
    end

    def raw
      @object.response
    end

  end

end
