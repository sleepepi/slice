module SubjectsHelper
  def status_helper(subject, long = false)
    codes = { 'valid' => 'success', 'test' => 'info' }
    content_tag(  :span, (long ? subject.status : subject.status[0]),
                  class: "label label-#{codes[subject.status.to_s] || 'warning'}",
                  rel: 'tooltip',
                  data: { placement: 'left' },
                  title: "#{subject.status unless long}" )
  end
end
