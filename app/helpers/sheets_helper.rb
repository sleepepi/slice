# Generates sheet coverage tag, and also links back to sheet index
module SheetsHelper
  def coverage_helper(sheet, placement = 'right')
    content_tag(:span, "#{sheet.percent}%",
                class: "label label-coverage #{sheet.coverage}",
                rel: 'tooltip',
                data: { container: 'body', placement: placement },
                title: sheet.out_of)
  end

  def filter_link(count, design, variable, value, statuses)
    params = { design_id: design.id, statuses: statuses }
    params[:f] = [{ variable_id: variable.id, value: value }] if variable
    url = project_sheets_path design.project, params
    link_to_if count.present?, count || '-', url, target: '_blank'
  end
end
