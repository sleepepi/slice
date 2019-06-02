# frozen_string_literal: true

# Generates project exports.
class ExportJob < ApplicationJob
  queue_as :sqs

  def perform(export)
    export.generate_export!
  end
end
