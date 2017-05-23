# frozen_string_literal: true

# Allows models to be searched.
module Searchable
  extend ActiveSupport::Concern

  included do
    # Search Scope
    def self.search(arg, match_start: true)
      term = \
        if match_start
          arg.to_s.downcase.gsub(/ |$/, "%")
        else
          arg.to_s.downcase.gsub(/^| |$/, "%")
        end
      terms = [term] * search_queries.count
      where search_queries.join(" or "), *terms
    end

    def self.search_queries
      searchable_attributes.collect do |searchable_attribute|
        "#{table_name}.#{searchable_attribute} ILIKE ?"
      end
    end

    def self.searchable_attributes
      %w(name description)
    end
  end
end
