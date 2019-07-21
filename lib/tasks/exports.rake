# frozen_string_literal: true

namespace :exports do
  desc "Recompute file sizes for all exports."
  task recompute_file_sizes: :environment do
    Export.find_each do |export|
      export.update(file_size: export.file.size)
    end
  end

  desc "Remove expired exports."
  task expire: :environment do
    unless ENV["JOB_SERVER"] == "true"
      puts "SKIP: Not running on job server."
      next
    end

    Export.expired.destroy_all
  end
end
