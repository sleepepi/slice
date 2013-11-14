module SubjectsHelper
  def status_helper(subject, long = false)
    content_tag(  :span, (long ? subject.status : subject.status[0]),
                  class: "label label-#{subject.status == 'valid' ? 'success' : 'info'}",
                  rel: 'tooltip',
                  data: { placement: 'left' },
                  title: "#{subject.status unless long}" )
  end
end
