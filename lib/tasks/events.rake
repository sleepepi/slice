namespace :events do

  desc 'Move designs from shedules to events'
  task populate_event_designs: :environment do
    event_design_count = EventDesign.count
    puts "There are #{Schedule.current.count} schedules across #{Schedule.current.uniq.pluck(:project_id).count} projects!"
    schedules = Schedule.current

    schedules.each do |schedule|
      puts "#{schedule.name} has #{schedule.items.collect{|item| item[:event_id]}.count} events"
      schedule.items.each do |item|
        event = schedule.project.events.find_by_id(item[:event_id])
        puts "Working on Event #{event.name}"
        puts "Event has #{event.designs.count} and will have #{item[:design_ids].count} designs"
        event.update( design_ids: (event.designs.pluck(:id) | item[:design_ids]) )
      end
    end

    puts "#{EventDesign.count - event_design_count} Event Designs were created."
  end

  desc 'Move sheets associated with a schedule, to a specific event instead'
  task move_schedules: :environment do
    subject_event_count = SubjectEvent.count
    puts "Moving schedules by subject"
    sheets = Sheet.current.where.not(subject_schedule_id: nil, event_id: nil)
    sheets.each do |sheet|
      if sheet.subject_schedule and sheet.event
        event_date = nil

        sheet.subject_schedule.schedule.sorted_items.each do |item|
          existing_event = sheet.project.events.find_by_id(item[:event_id])
          if existing_event == sheet.event
            event_date = sheet.subject_schedule.offset_date(item[:interval], item[:units])
            break
          end
        end

        subject_event = sheet.subject.subject_events.where( event: sheet.event, event_date: event_date ).first_or_create
        if subject_event
          sheet.update subject_event_id: subject_event.id
          # Remove subject schedule and event from subject as subject_event replaces this
          # sheet.update subject_schedule_id: nil, event_id: nil
        else
          puts "Updating Sheet ##{sheet.id}"
          puts "EVENT COULD NOT BE CREATED"
        end
      end
    end

    puts "#{SubjectEvent.count - subject_event_count} Subject Events were created."

  end
end
