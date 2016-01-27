# frozen_string_literal: true

require 'valuables/default'

module Valuables
  class FileAttachment < Default
    def name
      @object.response_file.size > 0 ? @object.response_file.to_s.split('/').last : ''
    end

    def raw
      @object.response_file
    end
  end
end
