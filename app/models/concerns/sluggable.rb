# frozen_string_literal: true

# Allows models with an id:integer and a slug:string to be found by either using
# find_by_param, and by overriding to_param for URL generation.
module Sluggable
  extend ActiveSupport::Concern

  included do
    def self.find_by_param(input)
      find_by "#{table_name}.slug = ? or #{table_name}.id = ?", input.to_param.to_s, input.to_param.to_i
    end
  end

  def to_param
    slug_was.blank? ? id.to_s : slug_was
  end
end
