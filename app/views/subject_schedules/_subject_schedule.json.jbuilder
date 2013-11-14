json.id subject_schedule.id
json.schedule_name subject_schedule.schedule.name
json.initial_due_date subject_schedule.initial_due_date
json.events subject_schedule.schedule.sorted_items.each do |item|
  if event = subject_schedule.subject.project.events.find_by_id(item[:event_id])
    json.event_name event.name
    json.event_date subject_schedule.offset_date(item[:interval], item[:units])
    item_design_ids = (item[:design_ids] || [])
    designs = subject_schedule.schedule.designs( item_design_ids )
    array_to_sort = []
    designs.each do |design|
      panel_hash = subject_schedule.panel_hash(item[:event_id], design.id)
      array_to_sort << [panel_hash[:order], panel_hash[:name], panel_hash[:css_class], design, item_design_ids.index(design.id.to_s)]
    end
    json.sheets array_to_sort.sort{ |a,b| [a[0], a[4]] <=> [b[0], b[4]] }.each do |order, panel_name, panel_class, design, position|
      if sheet = subject_schedule.sheet(event.id, design.id)
        json.name sheet.name
        json.sheet_id sheet.id
        json.status 'Entered'
      elsif event
        json.name design.name
        json.design_id design.id
        json.event_id event.id
        json.subject_schedule_id subject_schedule.id
        json.status 'Unentered'
      end
    end
  end
end
