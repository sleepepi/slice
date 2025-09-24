#!/bin/bash

echo "Rebuilding Puma with system OpenSSL 3.x..."

cd /var/app/current

# Clean up old native extensions
rm -rf vendor/bundle/ruby/*/gems/puma-*/ext

# Reconfigure bundler to rebuild Puma with system OpenSSL
bundle config build.puma --with-cflags="-I/usr/include" --with-ldflags="-L/usr/lib64"
bundle install