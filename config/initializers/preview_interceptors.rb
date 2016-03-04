ActionMailer::Base.register_preview_interceptor(ActionMailer::InlinePreviewInterceptor) if Rails.env.development?
