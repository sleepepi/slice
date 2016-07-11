# frozen_string_literal: true

class AboutChannel < ApplicationCable::Channel
  def self.broadcast
    ActionCable.server.broadcast 'about_sheets_channel',
      sheet_count: ExternalController.render(partial: 'external/sheet_count')
  end

  def subscribed
    stream_from 'about_sheets_channel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
