module Devise
  class Mailer < ApplicationMailer
    include Devise::Mailers::Helpers

    # def confirmation_instructions(record, token, opts={})
    #   setup_email
    #   @token = token
    #   devise_mail(record, :confirmation_instructions, opts)
    #   # mail(to: @email_to, subject: "confirmation_instructions")
    # end

    def reset_password_instructions(record, token, opts = {})
      setup_email
      # @user = @resource
      @email_to = record.email
      @token = token
      devise_mail(record, :reset_password_instructions, opts)
      # mail(to: @email_to, subject: "reset_password_instructions")
    end

    # def unlock_instructions(record, token, opts={})
    #   setup_email
    #   @token = token
    #   devise_mail(record, :unlock_instructions, opts)
    #   # mail(to: @email_to, subject: "unlock_instructions")
    # end
  end
end
