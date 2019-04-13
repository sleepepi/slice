# frozen_string_literal: true

module Formatters
  # Used to help format arrays of database responses for file variables.
  class FileFormatter < DefaultFormatter
    def name_response(response_file)
      response_file.to_s.split("/").last if response_file && response_file.size > 0
      # self[:response_file] # TODO: Change for Amazon S3...
    end

    # def raw_response(response_file)
    #   response_file
    # end
  end
end
