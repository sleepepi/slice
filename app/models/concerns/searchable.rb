# frozen_string_literal: true

# Allows models to be searched.
module Searchable
  extend ActiveSupport::Concern

  included do
    # Search Scope
    def self.search_any_order(args)
      terms = args.to_s.split(/\s/).collect do |arg|
        arg.to_s.downcase.gsub(/^| |$/, "%")
      end
      queries = [concat_ws] * terms.count
      where queries.join(" AND "), *terms
    end

    def self.concat_ws
      "concat_ws(' ', #{full_attributes.join(", ")}) ILIKE ?"
    end

    def self.full_attributes
      searchable_attributes.collect do |attribute|
        "#{table_name}.#{attribute}"
      end
    end

    def self.searchable_attributes
      %w(name description)
    end
  end
end
