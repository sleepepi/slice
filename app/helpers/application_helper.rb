module ApplicationHelper

  # Prints out '6 hours ago, Yesterday, 2 weeks ago, 5 months ago, 1 year ago'
  def recent_activity(past_time)
    return '' unless past_time.kind_of?(Time)
    time_ago_in_words(past_time)
    seconds_ago = (Time.now - past_time)
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
    checked ? '<i class="icon-ok"></i>'.html_safe : ''
  end

  def safe_url?(url)
    ['http', 'https', 'ftp', 'mailto'].include?(URI.parse(url).scheme) rescue false
  end

  def simple_markdown(text)
    markdown = Redcarpet::Markdown.new( Redcarpet::Render::HTML, no_intra_emphasis: true, fenced_code_blocks: true, autolink: true, strikethrough: true, superscript: true )
    target_link_as_blank(markdown.render(replace_numbers_with_ascii(text.to_s)))
  end

  private

    def target_link_as_blank(text)
      text.to_s.gsub(/<a(.*?)>/, '<a\1 target="_blank">').html_safe
    end

    def replace_numbers_with_ascii(text)
      text.gsub(/^[ \t]*(\d)/){|m| ascii_number($1)}
    end

    def ascii_number(number)
      "&##{(number.to_i + 48).to_s};"
    end

end
