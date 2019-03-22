# frozen_string_literal: true

# TODO: Remove task in v72+
namespace :sections do
  desc "Detach images from section model and append to design with reference in section description."
  task detach_images: :environment do
    Section.includes(design: :design_options).order("design_options.position").each do |section|
      next if section.image.blank?

      puts "Section ##{section.id} moving #{section.image&.file&.filename}."

      design = section.design

      image = design.design_images.create(
        project: design.project,
        user: section.user,
        file: section.image.file,
        byte_size: section.image.file.size,
        filename: section.image.file.filename,
        content_type: DesignImage.content_type(section.image.file.filename)
      )

      if image
        section.update(
          description: [section.description, "{img:#{image.number}}"].compact.join("\n"),
          remove_image: true
        )
      end
    end
  end
end
