# frozen_string_literal: true

# Base class for application models
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
