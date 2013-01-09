module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, lambda { |arg| where('LOWER(name) LIKE ? or LOWER(description) LIKE ?', arg.downcase.gsub(/^| |$/, '%'), arg.downcase.gsub(/^| |$/, '%')) }
  end

end
