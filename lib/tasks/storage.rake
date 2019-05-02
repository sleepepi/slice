# frozen_string_literal: true

# TODO: Remove in v75
namespace :storage do
  desc "Move exports into projects folder"
  task move_exports: :environment do
    exports = Export.all.order(:id)
    print "Moving Exports: 0 of 0"
    exports.each_with_index do |export, index|
      print "\rMoving Exports: #{counter(index, exports.size)}"
      next if export[:file].blank?

      file = File.join(CarrierWave::Uploader::Base.root, export.file.former_store_dir, export[:file])
      export.update file: File.open(file, "rb") if File.exist?(file)
    end
    puts ""
  end

  task move_sheet_variables: :environment do
    sheet_variables_count = SheetVariable.count
    print "Moving Sheet Variables: 0 of 0"
    SheetVariable.find_each.with_index do |sheet_variable, index|
      print "\rMoving Sheet Variables: #{counter(index, sheet_variables_count)}"
      next if sheet_variable[:response_file].blank?

      file = File.join(CarrierWave::Uploader::Base.root, sheet_variable.response_file.former_store_dir, sheet_variable[:response_file])
      sheet_variable.update response_file: File.open(file, "rb") if File.exist?(file)
    end
    puts ""
  end

  task move_adverse_event_files: :environment do
    adverse_event_files = AdverseEventFile.all.order(:id)
    print "Moving Adverse Event Files: 0 of 0"
    adverse_event_files.each_with_index do |adverse_event_file, index|
      print "\rMoving Adverse Event Files: #{counter(index, adverse_event_files.size)}"
      next if adverse_event_file[:attachment].blank?

      file = File.join(CarrierWave::Uploader::Base.root, adverse_event_file.attachment.former_store_dir, adverse_event_file[:attachment])
      adverse_event_file.update attachment: File.open(file, "rb") if File.exist?(file)
    end
    puts ""
  end

  task move_ae_document_files: :environment do
    ae_documents = AeDocument.all.order(:id)
    print "Moving AE Documents: 0 of 0"
    ae_documents.each_with_index do |ae_document, index|
      print "\rMoving AE Documents: #{counter(index, ae_documents.size)}"
      next if ae_document[:file].blank?

      file = File.join(CarrierWave::Uploader::Base.root, ae_document.file.former_store_dir, ae_document[:file])
      ae_document.update file: File.open(file, "rb") if File.exist?(file)
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
