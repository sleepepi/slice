module SheetsHelper

  def coverage_helper(sheet)
    content_tag(  :span, "#{sheet.percent}%",
                  class: "label label-coverage #{sheet.coverage}",
                  rel: 'tooltip',
                  data: { placement: 'right' },
                  title: sheet.out_of )
  end

end
