PDFKit.configure do |config|
  config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf'
  config.default_options = {
    :disable_external_links => true,
    :disable_internal_links => true
  #   :page_size => 'Legal',
  #   :print_media_type => true
  }
  # config.root_url = "http://localhost" # Use only if your external hostname is unavailable on the server.
end

class PDFKit

  class Middleware

    private

    def set_request_to_render_as_pdf(env)
      @render_pdf = true
      path = @request.path.sub(%r{\.pdf$}, '')
      path = path.sub(@request.script_name, '') # Added
      %w[PATH_INFO REQUEST_URI].each { |e| env[e] = path }
      env['HTTP_ACCEPT'] = concat(env['HTTP_ACCEPT'], Rack::Mime.mime_type('.html'))
      env["Rack-Middleware-PDFKit"] = "true"
    end

  end

end
