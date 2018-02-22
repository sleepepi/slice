# frozen_string_literal: true

# Methods to display time.
module TimeHelper
  def abbreviated_time(time_at)
    return "" if time_at.blank?
    time_ago_in_words(time_at)
      .gsub(/(about|less than|almost|over)\s/, "")
      .gsub(/minute/, "min")
      .gsub(/hour/, "hr")
      .gsub(/month/, "mo")
      .gsub(/year/, "yr") + " ago"
  end
end
