# frozen_string_literal: true

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
      if @object.response.blank?
        nil
      else
        @object.response
      end
    end

    def display_name
      name
    end
  end
end
