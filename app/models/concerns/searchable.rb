module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, lambda { |arg| where('LOWER(name) LIKE ? or LOWER(description) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')) }
  end

end
