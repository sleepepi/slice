module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, lambda { |arg| where("LOWER(#{self.table_name}.name) LIKE ? or LOWER(#{self.table_name}.description) LIKE ?", arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')) }
  end

end
