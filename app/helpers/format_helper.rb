# frozen_string_literal: true

# Helps style simple markdown tags.
module FormatHelper
  def simple_style(text)
    tags = [["\\*\\*", "strong"], ["__", "span", "text-decoration: underline;"], ["==", "mark"], ["\\*", "em"]]
    tags.each do |markup, tag, style|
      text.gsub!(/#{markup}(.*?)#{markup}/, "<#{tag}#{" style=\"#{style}\"" if style.present?}>\\1</#{tag}>")
    end
    sanitize(text, tags: tags.collect(&:second), attributes: %w(style))
  end
end
