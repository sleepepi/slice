# frozen_string_literal: true

# Helps simplify links across screen sizes for headers.
module HeaderHelper
  def plus_or(label)
    span_xs_sm = content_tag :span, class: 'hidden-md hidden-lg' do
      content_tag :i, nil, class: %w(fa fa-plus), aria: { hidden: 'true' }
    end
    span_md_lg = content_tag :span, label, class: %w(hidden-xs hidden-sm)
    span_xs_sm + span_md_lg
  end
end
