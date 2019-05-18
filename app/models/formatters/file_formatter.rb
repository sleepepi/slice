# frozen_string_literal: true

module Formatters
  # Used to help format arrays of database responses for file variables.
  class FileFormatter < DefaultFormatter
    def name_response(valuable)
      if valuable.respond_to?(:response_file)
        valuable[:response_file]
      else
        valuable
      end
    end

    def raw_response(valuable)
      if valuable.respond_to?(:response_file)
        valuable.response_file
      else
        valuable
      end
    end
  end
end
