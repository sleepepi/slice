module SheetsHelper

  def coverage_helper(sheet)
    content_tag(  :span, "#{sheet.percent}%",
                  class: "label label-coverage #{sheet.coverage}",
                  rel: 'tooltip',
                  data: { placement: 'right' },
                  title: sheet.out_of )
  end

  def filter_link(count, project, design, variable, value, statuses)
    variable_id = variable ? variable.id : nil
    link_to_if( !count.blank?, count || '-', project_sheets_path(project, design_id: design.id, f: [{ variable_id: variable_id, value: value }], statuses: statuses), target: '_blank' )
  end

end
