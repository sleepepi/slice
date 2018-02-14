# frozen_string_literal: true

# Updates layout for devise registrations pages.
class RegistrationsController < Devise::RegistrationsController
  layout "layouts/full_page"
end
