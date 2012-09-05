source 'https://rubygems.org'

gem 'rails',                '3.2.8'

# Database Adapter
# Install instructions for Windows: http://blog.mmediasys.com/2011/07/07/installing-mysql-on-windows-7-x64-and-using-ruby-with-it/
gem 'mysql2',               '0.3.11'
gem 'thin',                 '~> 1.4.1',           :platforms => [ :mswin, :mingw ]
gem 'eventmachine',         '~> 1.0.0.rc.4',      :platforms => [ :mswin, :mingw ]

# Gems used by project
gem 'contour',              '~> 1.1.0.rc2'
gem 'kaminari',             '~> 0.14.0'
gem 'carrierwave',          '~> 0.6.2'
gem 'pdfkit',               '~> 0.5.2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',         '~> 3.2.5'
  gem 'coffee-rails',       '~> 3.2.2'
  gem 'uglifier',           '>= 1.0.3'
end

gem 'jquery-rails'

# Testing
group :test do
  # Pretty printed test output
  gem 'win32console',                             :platforms => [ :mswin, :mingw ]
  gem 'turn',               '~> 0.9.6'
  gem 'simplecov',          '~> 0.6.4',           :require => false
end
