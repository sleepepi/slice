# frozen_string_literal: true

# Renders text written with markdown.
module MarkdownHelper
  def simple_markdown_new(text, target_blank: true, table_class: "", allow_links: true, allow_images: true, allow_tables: true, allow_lists: true, pretend_links: false)
    result = text.to_s
    result = replace_numbers_with_ascii(result) unless allow_lists
    result = redcarpet_markdown.render(result)
    result = result.encode("UTF-16", undef: :replace, invalid: :replace, replace: "").encode("UTF-8")
    result = add_table_class(result, table_class) unless table_class.blank?
    result = remove_links(result) unless allow_links
    result = pretend_links(result) if pretend_links
    if allow_images
      result = wrap_images(result)
    else
      result = remove_images(result)
    end
    result = remove_tables(result) unless allow_tables
    result = target_link_as_blank(result) if target_blank
    result.html_safe
  end

  def target_link_as_blank(text)
    text.to_s.gsub(/<a(.*?)>/m, "<a\\1 target=\"_blank\">").html_safe
  end

  def remove_links(text)
    text.to_s.gsub(%r{<a[^>]*? href="(.*?)">(.*?)</a>}m, "\\2")
  end

  def pretend_links(text)
    text.to_s.gsub(%r{<a[^>]*? href="(.*?)">(.*?)</a>}m, "<span class=\"text-primary\">\\2</span>")
  end

  def wrap_images(text)
    text.to_s.gsub(/(<img.*?>)/m, "<div class=\"img-zoom-message\">\\1</div>")
  end

  def remove_images(text)
    text.to_s.gsub(/<img src="(.*?)"(.*?)>/m, "<div>\\1</div>")
  end

  def remove_tables(text)
    text.to_s.gsub(%r{<table(.*?)>(.*?)</table>}m, "")
  end

  def add_table_class(text, table_class)
    text.to_s.gsub(/<table>/m, "<table class=\"#{table_class}\">").html_safe
  end

  def replace_numbers_with_ascii(text)
    text.gsub(/^[ \t]*(\d)/) { |m| ascii_number($1) }
  end

  def ascii_number(number)
    "&##{number.to_i + 48};"
  end

  def redcarpet_markdown
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      autolink: true,
      strikethrough: true,
      superscript: true,
      tables: true,
      lax_spacing: true,
      space_after_headers: true,
      underline: true,
      highlight: true,
      footnotes: true
    )
  end
end
