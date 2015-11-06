# Allows JS to poll to see if a user is currently logged in or not
class TimeoutController < ApplicationController
  prepend_before_action { request.env['devise.skip_trackable'] = true }
  prepend_before_action { request.env['slice.skip_warden_401'] = true }

  def check
  end
end
