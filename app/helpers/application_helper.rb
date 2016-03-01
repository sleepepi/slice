# frozen_string_literal: true

# Provides general application helper methods for HAML views
module ApplicationHelper
  include DateAndTimeParser

  def th_sort_field(order, sort_field, display_name)
    sort_field_order = (order == sort_field) ? "#{sort_field} DESC" : sort_field
    if order == sort_field
      css_class = 'sort-up'
      selected_class = 'sort-selected'
    elsif order == sort_field + ' DESC'
      css_class = 'sort-down'
      selected_class = 'sort-selected'
    end
    content_tag(:th, class: ['nowrap', selected_class]) do
      link_to url_for(params.merge(order: sort_field_order)), style: 'text-decoration:none', class: css_class do
        display_name.to_s.html_safe
      end
    end.html_safe
  end

  # Prints out '6 hours ago, Yesterday, 2 weeks ago, 5 months ago, 1 year ago'
  def recent_activity(past_time)
    return '' unless past_time.is_a?(Time)
    time_ago_in_words(past_time)
    seconds_ago = (Time.zone.now - past_time)
    color = if seconds_ago < 60.minute then "#6DD1EC"
    elsif seconds_ago < 1.day then "#ADDD1E"
    elsif seconds_ago < 2.day then "#CEDC34"
    elsif seconds_ago < 1.week then "#CEDC34"
    elsif seconds_ago < 1.month then "#DCAA24"
    elsif seconds_ago < 1.year then "#C2692A"
    else "#AA2D2F"
    end
    "<span style='color:#{color};font-weight:bold;font-variant:small-caps;'>#{time_ago_in_words(past_time)} ago</span>".html_safe
  end

  def simple_date(past_date)
    return '' if past_date.blank?
    if past_date == Date.today
      'Today'
    elsif past_date == Date.today - 1.day
      'Yesterday'
    elsif past_date == Date.today + 1.day
      'Tomorrow'
    elsif past_date.year == Date.today.year
      past_date.strftime("%b %d")
    else
      past_date.strftime("%b %d, %Y")
    end
  end

  def simple_time(past_time)
    return '' if past_time.blank?
    if past_time.to_date == Date.today
      past_time.strftime("<b>Today</b> at %I:%M %p").html_safe
    elsif past_time.year == Date.today.year
      past_time.strftime("on %b %d at %I:%M %p")
    else
      past_time.strftime("on %b %d, %Y at %I:%M %p")
    end
  end

  def simple_check(checked)
    checked ? '<span class="glyphicon glyphicon-ok"></span>'.html_safe : ''
  end

  def simple_check_new(checked)
    if checked
      content_tag :span, nil, class: %w(glyphicon glyphicon-ok text-success)
    else
      content_tag :span, nil, class: %w(glyphicon glyphicon-minus text-danger)
    end
  end

  def safe_url?(url)
    ['http', 'https', 'ftp', 'mailto'].include?(URI.parse(url).scheme) rescue false
  end

  def simple_markdown(text, table_class = '')
    markdown = Redcarpet::Markdown.new( Redcarpet::Render::HTML, no_intra_emphasis: true, fenced_code_blocks: true, autolink: true, strikethrough: true, superscript: true, tables: true, lax_spacing: true, space_after_headers: true, underline: true, highlight: true, footnotes: true )
    result = replace_numbers_with_ascii(text.to_s)
    result = markdown.render(result)
    result = result.encode('UTF-16', undef: :replace, invalid: :replace, replace: "").encode('UTF-8')
    result = add_table_class(result, table_class) unless table_class.blank?
    result = target_link_as_blank(result)
    result.html_safe
  end

  def beta_enabled?(current_user)
    current_user && current_user.beta_enabled?
  end

  private

  def target_link_as_blank(text)
    text.to_s.gsub(/<a(.*?)>/m, '<a\1 target="_blank">').html_safe
  end

  def replace_numbers_with_ascii(text)
    text.gsub(/^[ \t]*(\d)/){|m| ascii_number($1)}
  end

  def ascii_number(number)
    "&##{(number.to_i + 48).to_s};"
  end

  def add_table_class(text, table_class)
    text.to_s.gsub(/<table>/m, "<table class=\"#{table_class}\">").html_safe
  end
end
