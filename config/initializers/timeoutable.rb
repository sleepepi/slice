# frozen_string_literal: true

# Overwrite the warden error that is currently in Devise

Warden::Manager.after_set_user do |record, warden, options|
  scope = options[:scope]
  env   = warden.request.env

  if record && record.respond_to?(:timedout?) && warden.authenticated?(scope) &&
     options[:store] != false && !env['devise.skip_timeoutable']
    last_request_at = warden.session(scope)['last_request_at']

    if last_request_at.is_a?(Integer)
      last_request_at = Time.zone.at(last_request_at)
    elsif last_request_at.is_a?(String)
      last_request_at = Time.zone.parse(last_request_at)
    end

    proxy = Devise::Hooks::Proxy.new(warden)

    if record.timedout?(last_request_at) && !env['devise.skip_timeout']
      Devise.sign_out_all_scopes ? proxy.sign_out : proxy.sign_out(scope)

      throw :warden, scope: scope, message: :timeout if !env['slice.skip_warden_401']
    end

    unless env['devise.skip_trackable']
      warden.session(scope)['last_request_at'] = Time.zone.now.utc.to_i
    end
  end
end
