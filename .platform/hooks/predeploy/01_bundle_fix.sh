#!/bin/bash
set -e

echo "Starting bundle fix..."
cd /var/app/staging

# Log current state
echo "Current directory: $(pwd)"
echo "Ruby version: $(ruby -v)"
echo "Bundler version: $(bundle -v)"

# Clean and reinstall
bundle clean --force
bundle config --local force_ruby_platform true
bundle install --deployment --without development test

echo "Bundle fix completed successfully"