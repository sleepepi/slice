# frozen_string_literal: true

module Slicers
  # Provides default methods for checking variables and saving to database.
  class CheckboxSlicer < DomainSlicer
    def save(values)
      # Could use pluck, but pluck has issues with scopes and unsaved objects
      old_response_ids = object.responses.collect(&:id)
      object.responses = clean_values(values).collect do |value|
        Response.where(response_update_hash(value)).first_or_create(user: @current_user)
      end
      Response.where(id: old_response_ids, class_foreign_key => nil).destroy_all
      true
    end

    private

    def clean_values(values)
      if values.is_a?(Array)
        values.select(&:present?)
      else
        []
      end
    end

    def class_foreign_key
      @class_foreign_key ||= "#{object.class.name.underscore}_id".to_sym
    end

    def response_update_hash(value)
      format_for_db_update(value).merge!(
        class_foreign_key => object.id,
        sheet_id: @sheet.id,
        variable_id: @variable.id
      )
    end
  end
end
