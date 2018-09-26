# frozen_string_literal: true

module Engine
  class Sed
    def self.skip?(seds1, seds2)
      return false if seds1.blank? || seds2.blank?
      seds1.each do |sed1|
        seds2.each do |sed2|
          return false if sed1.event_id != sed2.event_id
          return false if sed1.design_id != sed2.design_id
          return false if sed1.sheet_id == sed2.sheet_id
        end
      end
      true
    end

    attr_accessor :sheet_id, :event_id, :design_id

    def initialize(sheet_id: nil, event_id: nil, design_id: nil)
      @sheet_id = sheet_id
      @event_id = event_id
      @design_id = design_id
    end

    def values
      [@sheet_id, @event_id, @design_id]
    end
  end
end
