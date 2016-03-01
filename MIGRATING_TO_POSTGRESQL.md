Migrating to PostgreSQL
=======================

Based on [RailsCasts 342](http://railscasts.com/episodes/342-migrating-to-postgresql?view=asciicast).

The following files will need to be updated:

* `config/database.yml`
* `Gemfile`

## config/database.yml

```yaml
# PostgreSQL. Versions 8.2 and up are supported.

development:
  adapter: postgresql
  encoding: unicode
  pool: 5
  timeout: 5000
  database: slice_development
  username: username
  password: password
  # socket:
  # host:

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  adapter: postgresql
  encoding: unicode
  pool: 5
  timeout: 5000
  database: slice_test
  username: username
  password: password
  # socket:
  # host:

production:
  adapter: postgresql
  encoding: unicode
  pool: 5
  timeout: 5000
  database: slice_production
  username: username
  password: password
  # socket:
  # host:
```

## Gemfile

```ruby
gem 'pg',                   '0.14.1'
```

## Migrate data from MySQL to PostgreSQL

```
bundle update

# At this point update your database.yml file to point to the PostgreSQL database

bundle exec rake db:create RAILS_ENV=production

gem install taps --no-ri --no-rdoc

sudo yum install sqlite-devel
gem install sqlite3 --no-ri --no-rdoc

taps server mysql2://localdbuser:localdbpass@localhost/dbname?encoding=latin1 httpuser httppassword

taps pull postgres://username:password@localhost/slice_production http://httpuser:httppassword@localhost:5000
```
