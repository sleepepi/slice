# frozen_string_literal: true

json.overall @project.overall_grades

json.sites @project.sites.order_number_and_name.collect(&:number_and_short_name)

json.events @project.event_grades
