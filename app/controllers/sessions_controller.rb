# frozen_string_literal: true

# Override for devise sessions controller in order to track a user's location
# when signing out.
class SessionsController < Devise::SessionsController
  layout "layouts/full_page"
end
