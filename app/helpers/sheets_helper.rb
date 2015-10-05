module SheetsHelper
  def coverage_helper(sheet, placement = 'right')
    content_tag(:span, "#{sheet.percent}%",
                class: "label label-coverage #{sheet.coverage}",
                rel: 'tooltip',
                data: { placement: placement },
                title: sheet.out_of)
  end

  def filter_link(count, project, design, variable, value, statuses)
    if variable
      link_to_if( !count.blank?, count || '-', project_sheets_path(project, design_id: design.id, f: [{ variable_id: variable.id, value: value }], statuses: statuses), target: '_blank' )
    else
      link_to_if( !count.blank?, count || '-', project_sheets_path(project, design_id: design.id, statuses: statuses), target: '_blank' )
    end
  end
end
