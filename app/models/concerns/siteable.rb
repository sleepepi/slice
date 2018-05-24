# frozen_string_literal: true

# Allows models to be filtered by site.
module Siteable
  extend ActiveSupport::Concern

  included do
    def self.with_site(arg)
      joins(:subject).merge(Subject.current.where(site_id: arg))
    end
  end
end
