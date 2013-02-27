class Authentication < ActiveRecord::Base
  # Concerns
  include ContourAuthenticatable
end
