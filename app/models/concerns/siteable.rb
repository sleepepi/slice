module Siteable
  extend ActiveSupport::Concern

  included do
    def self.with_site(arg)
      joins(:subject).merge Subject.current.where(site_id: arg)
    end
  end
end
