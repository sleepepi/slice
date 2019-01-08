# frozen_string_literal: true

# Allows models to have a shortened version of their name.
module ShortNameable
  extend ActiveSupport::Concern

  def short_name
    return self[:short_name] if self[:short_name].present?

    computed_short_name
  end

  def computed_short_name
    return self[:name] if self[:name].to_s.split(/\s/).count <= 1

    s = self[:name].gsub(/(\b\w)([\w']*)/) { Regexp.last_match[1] }
    s.to_s.gsub(/\s/, "")
  end
end
