# frozen_string_literal: true

# TODO: Remove in v75
namespace :storage do
  desc "Move exports into projects folder"
  task move_exports: :environment do
    exports = Export.all
    print "Moving Exports: 0 of 0"
    Export.order(:id).each_with_index do |export, index|
      print "\rMoving Exports: #{counter(index, exports.size)}"
      next if export[:file].blank?

      file = File.join(CarrierWave::Uploader::Base.root, export.file.former_store_dir, export[:file])
      export.update file: File.open(file, "rb") if File.exist?(file)
    end
    puts ""
  end
end

def counter(index, total)
  "#{counter_string(index, total)} #{percent_string(index, total)}"
end

def counter_string(index, total)
  "#{index + 1} of #{total}"
end
# END TODO: Remove in v75
