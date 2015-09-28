module Searchable
  extend ActiveSupport::Concern

  included do
    # Search Scope
    def self.search(arg)
      term = arg.to_s.downcase.gsub(/^| |$/, '%')
      terms = [term] * search_queries.count
      where search_queries.join(' or '), *terms
    end

    def self.search_queries
      searchable_attributes.collect do |searchable_attribute|
        "LOWER(#{table_name}.#{searchable_attribute}) LIKE ?"
      end
    end

    def self.searchable_attributes
      %w(name description)
    end
  end
end
