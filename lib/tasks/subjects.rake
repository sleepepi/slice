# frozen_string_literal: true

namespace :subjects do
  desc "Recompute uploaded file counts"
  task reset_uploaded_file_counts: :environment do
    print "Resetting sheet uploaded files counts..."
    Subject.find_each(&:update_uploaded_file_counts!)
    puts "DONE"
  end
end
