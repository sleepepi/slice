class Authentication < ActiveRecord::Base
  # Concerns
  include ContourAuthenticatable

  default_scope { none }

end
