# frozen_string_literal: true

json.array! @project.medication_templates.search_any_order(params[:search]).pluck(:name)
