# frozen_string_literal: true

# Allows models to be filtered by site.
module Siteable
  extend ActiveSupport::Concern

  included do
    def self.with_site(arg)
      # TODO: The merge is preferred, however does not work with buildable.rb at
      # the moment
      # joins(:subject).merge(Subject.current.where(site_id: arg))
      joins(:subject).where(subjects: { deleted: false, site_id: arg })
    end
  end
end
