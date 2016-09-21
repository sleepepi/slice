# frozen_string_literal: true

# Helps simplify links across screen sizes for headers.
module HeaderHelper
  def plus_or(label)
    label_or(label, plus_tag)
  end

  def label_or(label, small_label)
    span_xs_sm = content_tag :span, class: 'hidden-md hidden-lg' do
      small_label
    end
    span_md_lg = content_tag :span, label, class: %w(hidden-xs hidden-sm)
    span_xs_sm + span_md_lg
  end

  def plus_tag
    content_tag :i, nil, class: %w(fa fa-plus), aria: { hidden: 'true' }
  end
end
