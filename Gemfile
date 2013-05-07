source 'https://rubygems.org'

gem 'rails',                '4.0.0.rc1'

# Database Adapter
gem 'pg',                   '0.15.1'
gem 'thin',                 '~> 1.5.0',           platforms: [ :mswin, :mingw ]
gem 'eventmachine',         '~> 1.0.0',           platforms: [ :mswin, :mingw ]

# Gems used by project
gem 'contour',              '2.0.0.beta.7'
gem 'devise',               '~> 2.2.3',           github: 'plataformatec/devise', ref: 'c618969'     # , branch: 'rails4' # newer
# gem 'devise',               '~> 2.2.3',           github: 'plataformatec/devise', ref: 'd29b744'   # , branch: 'rails4' # older
gem 'kaminari',             '~> 0.14.1'
gem 'carrierwave',          '~> 0.7.1'
# gem 'audited-activerecord', '~> 3.0.0'
gem 'rails-observers',      '0.1.1'
# gem 'audited-activerecord', '3.0.0.rails4',       github: 'remomueller/audited', branch: 'rails4'

gem 'systemu',              '~> 2.5.2'
gem 'rubyzip',              '~> 0.9.9'
gem 'mail_view',            '~> 1.0.3'
gem 'naturalsort',          '~> 1.1.1'
gem 'ruby-ntlm-namespace',  '~> 0.0.1'
gem 'redcarpet',            '~> 2.2.2'

# Rails Defaults
gem 'coffee-rails',         '~> 4.0.0'
gem 'sass-rails',           '~> 4.0.0.rc1'
gem 'uglifier',             '>= 1.3.0'

gem 'jbuilder',             '~> 1.4.0'
gem 'jquery-rails'
gem 'turbolinks'

# Testing
group :test do
  # Pretty printed test output
  gem 'win32console',                             platforms: [ :mswin, :mingw ]
  gem 'turn',               '~> 0.9.6'
  gem 'simplecov',          '~> 0.7.1',           require: false
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
