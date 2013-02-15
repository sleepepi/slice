# Slice

[![Build Status](https://travis-ci.org/remomueller/slice.png?branch=master)](https://travis-ci.org/remomueller/slice)
[![Dependency Status](https://gemnasium.com/remomueller/slice.png)](https://gemnasium.com/remomueller/slice)
[![Code Climate](https://codeclimate.com/github/remomueller/slice.png)](https://codeclimate.com/github/remomueller/slice)

A clinical research interface geared at collecting robust and consistent data by providing a strong framework for designing data dictionaries and collection forms. Slice also provides exports of the data and the data dictionaries created as well as providing a simple reporting interface. Using Rails 3.2+ and Ruby 1.9.3+.

## Installation

[Prerequisites Install Guide](https://github.com/remomueller/documentation): Instructions for installing prerequisites like Ruby, Git, JavaScript compiler, etc.

Once you have the prerequisites in place, you can proceed to install bundler which will handle most of the remaining dependencies.

```console
gem install bundler
```

This readme assumes the following installation directory: /var/www/slice

```console
cd /var/www

git clone git://github.com/remomueller/slice.git

cd slice

bundle install
```

Install default configuration files for database connection, email server connection, server url, and application name.

```console
ruby lib/initial_setup.rb

bundle exec rake db:migrate RAILS_ENV=production

bundle exec rake assets:precompile
```

Run Rails Server (or use Apache or nginx)

```console
rails s -p80
```

Open a browser and go to: [http://localhost](http://localhost)

All done!

## Contributing to Slice

- Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
- Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
- Fork the project
- Start a feature/bugfix branch
- Commit and push until you are happy with your contribution
- Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright [![Creative Commons 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/80x15.png)](http://creativecommons.org/licenses/by-nc-sa/3.0)

Copyright (c) 2013 Remo Mueller. See [LICENSE](https://github.com/remomueller/slice/blob/master/LICENSE) for further details.
