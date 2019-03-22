# frozen_string_literal: true

# Provides general application helper methods for HAML views
module ApplicationHelper
  include DateAndTimeParser

  def th_sort_field_rev(order, sort_field, display_name, extra_class: "", permit: [])
    permit_options = [:search] + permit
    sort_params = params.permit(*permit_options)
    sort_field_order = (order == "#{sort_field} desc" || order == "#{sort_field} desc nulls last") ? sort_field : "#{sort_field} desc"
    if order == sort_field
      selected_class = "sort-selected"
    elsif order == "#{sort_field} desc nulls last" || order == "#{sort_field} desc"
      selected_class = "sort-selected"
    end
    content_tag(:th, class: [selected_class, extra_class]) do
      link_to url_for(sort_params.merge(order: sort_field_order)), style: "text-decoration: none;" do
        display_name.to_s.html_safe
      end
    end.html_safe
  end

  def th_sort_field(order, sort_field, display_name, extra_class: "", permit: [])
    permit_options = [:search] + permit
    sort_params = params.permit(*permit_options)
    sort_field_order = (order == sort_field) ? "#{sort_field} desc" : sort_field
    if order == sort_field
      selected_class = "sort-selected"
    elsif order == "#{sort_field} desc nulls last" || order == "#{sort_field} desc"
      selected_class = "sort-selected"
    end
    content_tag(:th, class: [selected_class, extra_class]) do
      link_to url_for(sort_params.merge(order: sort_field_order)), style: "text-decoration: none;" do
        display_name.to_s.html_safe
      end
    end.html_safe
  end

  def simple_date(past_date)
    return "" if past_date.blank?
    if past_date == Time.zone.today
      "Today"
    elsif past_date == Time.zone.today - 1.day
      "Yesterday"
    elsif past_date == Time.zone.today + 1.day
      "Tomorrow"
    elsif past_date.year == Time.zone.today.year
      past_date.strftime("%b %-d")
    else
      past_date.strftime("%b %-d, %Y")
    end
  end

  def format_date(date)
    return "" if date.blank?
    date.strftime("%b %-d, %Y")
  end

  def simple_time(past_time)
    return "" if past_time.blank?
    if past_time.to_date == Time.zone.today
      past_time.strftime("Today at %-I:%M %p")
    elsif past_time.year == Time.zone.today.year
      past_time.strftime("on %b %-d at %-I:%M %p")
    else
      past_time.strftime("on %b %-d, %Y at %-I:%M %p")
    end
  end

  def simple_time_short(past_time)
    return "" if past_time.blank?
    if past_time.year == Time.zone.today.year
      past_time.strftime("%b %-d, %-I:%M %p")
    else
      past_time.strftime("%b %-d, %Y, %-I:%M %p")
    end
  end

  def simple_check(checked)
    checked ? icon("fas", "check-square") : icon("far", "square")
  end

  def simple_markdown_old(text, table_class = "")
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, no_intra_emphasis: true, fenced_code_blocks: true, autolink: true, strikethrough: true, superscript: true, tables: true, lax_spacing: true, space_after_headers: true, underline: true, highlight: true, footnotes: true)
    result = replace_numbers_with_ascii(text.to_s)
    result = markdown.render(result)
    result = result.encode("UTF-16", undef: :replace, invalid: :replace, replace: "").encode("UTF-8")
    result = add_table_class(result, table_class) unless table_class.blank?
    result = target_link_as_blank(result)
    result.html_safe
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
