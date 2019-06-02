# frozen_string_literal: true

# Generates project exports.
class ExportJob < ApplicationJob
  queue_as :slice_standard_queue

  def perform(export)
    export.generate_export!
  end
end
