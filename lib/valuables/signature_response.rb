require 'valuables/default'
require 'chunky_png'
require 'tempfile'

module Valuables

  class SignatureResponse < Default

    def raw_file
      file = Tempfile.new('signature.png')
      begin
        create_signature_png(@object.response, file.path)
        file.define_singleton_method(:original_filename) do
          'signature.png'
        end
        @object.response_file = file
        @object.save
      ensure
         file.close
         file.unlink   # deletes the temp file
      end

      @object.response_file
    end

    private

    def create_signature_png(signature, filename)
      canvas = ChunkyPNG::Canvas.new(300, 55)
      (JSON.parse(signature) rescue []).each do |hash|
        canvas.line( hash['mx'],  hash['my'], hash['lx'], hash['ly'], ChunkyPNG::Color.parse("#145394"))
      end
      png = canvas.to_image
      png.save(filename)
    end

  end

end
