module Latexable
  extend ActiveSupport::Concern

  included do
    def self.generate_pdf(jobname, output_folder, file_tex)
      # Run twice to allow LaTeX to compile correctly (page numbers, etc)
      `#{LATEX_LOCATION} -interaction=nonstopmode --jobname=#{jobname} --output-directory=#{output_folder} #{file_tex}`
      `#{LATEX_LOCATION} -interaction=nonstopmode --jobname=#{jobname} --output-directory=#{output_folder} #{file_tex}`

      File.join('tmp', 'files', 'tex', "#{jobname}.pdf") # Return file name
    end
  end

  def latex_safe(text)
    replacements.inject(text.to_s) do |corpus, (pattern, replacement)|
      corpus.gsub(pattern, replacement)
    end
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
      [/([_$&%#])/, '\\\\\1']
    ]
  end

end
