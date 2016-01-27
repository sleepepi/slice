# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register 'text/richtext', :rtf
# Mime::Type.register_alias 'text/html', :iphone
Mime::Type.register_alias 'text/csv', :raw_csv
Mime::Type.register_alias 'text/csv', :labeled_csv
# Mime::Type.register_alias 'application/xls', :xls
# Mime::Type.register 'application/xls', :xls
Mime::Type.register 'application/vnd.ms-excel', :xls
