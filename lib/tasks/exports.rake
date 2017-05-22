# frozen_string_literal: true

namespace :exports do
  desc "Recompute file sizes for all exports."
  task recompute_file_sizes: :environment do
    Export.find_each do |export|
      export.update(file_size: export.file.size)
    end
  end
end
