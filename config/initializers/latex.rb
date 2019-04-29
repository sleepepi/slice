# frozen_string_literal: true

# Set pdflatex location for AWS environment.

ENV["latex_location"] = "/usr/bin/pdflatex" if ENV["AMAZON"].to_s == "true"
