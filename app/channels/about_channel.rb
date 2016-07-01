# frozen_string_literal: true

# Be sure to restart your server when you modify this file. Action Cable runs in
# a loop that does not support auto reloading.
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
