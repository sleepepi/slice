# frozen_string_literal: true

# Methods to display time.
module TimeHelper
  def abbreviated_time(time_at)
    return "" if time_at.blank?

    shorten_time_words(time_ago_in_words(time_at)) + " ago"
  end

  def shorten_time_words(string)
    string.gsub(/(about|less than|almost|over)\s/, "")
          .gsub(/minute/, "min")
          .gsub(/hour/, "hr")
          .gsub(/month/, "mo")
          .gsub(/year/, "yr")
  end

  # Prints out "6 hours ago, Yesterday, 2 weeks ago, 5 months ago, 1 year ago"
  def recent_activity(past_time)
    return "" unless past_time.is_a?(Time)

    seconds_ago = (Time.zone.now - past_time)
    badge_class = \
      if seconds_ago < 60.minutes then "coverage-100"
      elsif seconds_ago < 1.day then "coverage-80"
      elsif seconds_ago < 2.days then "coverage-70"
      elsif seconds_ago < 1.week then "coverage-50"
      elsif seconds_ago < 1.month then "coverage-20"
      elsif seconds_ago < 1.year then "coverage-10"
      else "coverage-0"
      end
    content_tag(:span, abbreviated_time(past_time), class: "badge badge-coverage #{badge_class}")
  end
end
