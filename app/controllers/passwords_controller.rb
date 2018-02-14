# frozen_string_literal: true

# Override for devise passwords controller.
class PasswordsController < Devise::PasswordsController
  layout "layouts/full_page"
end
