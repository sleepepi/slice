# frozen_string_literal: true

# Allows view files to be setup that get rendered as PDF.
module Latexable
  extend ActiveSupport::Concern

  included do
    def self.latex_safe(text)
      new.latex_safe(text)
    end

    def self.latex_simple_style(text)
      new.latex_simple_style(text)
    end

    def self.compile(jobname, output_folder, file_tex)
      array = []
      array << ENV["latex_location"]
      array << "-interaction=nonstopmode"
      array << "--jobname=#{jobname}"
      array << "--output-directory=#{output_folder}"
      array << file_tex.to_s
      command = array.join(" ")
      # Run twice to allow LaTeX to compile correctly (page numbers, etc)
      `#{command}`
      `#{command}`
    end
  end

  def latex_safe(text)
    replacements.inject(text.to_s) do |corpus, (pattern, replacement)|
      corpus.gsub(pattern, replacement)
    end
  end

  def latex_simple_style(text)
    text = latex_safe(text)
    tags.each do |markup, tag|
      text.gsub!(/#{markup}(.*?)#{markup}/, tag)
    end
    text
  end

  # List of replacements
  def replacements
    @replacements ||= [
      [/([{}])/,    '\\\\\1'],
      [/\\/,        '\textbackslash{}'],
      [/\^/,        '\textasciicircum{}'],
      [/~/,         '\textasciitilde{}'],
      [/\|/,        '\textbar{}'],
      [/\</,        '\textless{}'],
      [/\>/,        '\textgreater{}'],
      [/([_$&%#])/, '\\\\\1'],
      # Languages (es)
      [/á/, "\\\\'a"],
      [/é/, "\\\\'e"],
      [/í/, "\\\\'i"],
      [/ó/, "\\\\'o"],
      [/ú/, "\\\\'u"],
      [/ü/, "\\\\\"u"],
      [/ñ/, "\\\\~n"],
      [/Á/, "\\\\'A"],
      [/É/, "\\\\'E"],
      [/Í/, "\\\\'I"],
      [/Ó/, "\\\\'O"],
      [/Ú/, "\\\\'U"],
      [/Ü/, "\\\\\"U"],
      [/Ñ/, "\\\\~N"],
      [/¿/, "?`"],
      [/¡/, "!`"]
    ]
  end

  def tags
    @tags ||= [
      ["\\*\\*", "\\textbf{\\1}"],
      ["\\\\_\\\\_", "\\underline{\\1}"],
      ["==", "\\hl{\\1}"],
      ["\\*", "\\\\textit{\\1}"]
    ]
  end
end
