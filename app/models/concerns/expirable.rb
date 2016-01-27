# frozen_string_literal: true

# Tracks password expiration
module Expirable
  extend ActiveSupport::Concern

  included do
    EXPIRE_PASSWORD_AFTER = 180.days
    PASSWORD_ARCHIVE = 5
    has_many :old_passwords
  end

  # Send emails 1, 5, 15, and 30 days before password expires
  def password_expires_soon?
    [1, 5, 15, 30].include? password_expires_in
  end

  def password_expires_today?
    password_expires_in == 0
  end

  def password_expires_in
    (password_expires_on.to_date - Time.zone.today).to_i
  end

  def password_expires_on
    update password_changed_at: Time.zone.now if password_changed_at.blank?
    password_changed_at + EXPIRE_PASSWORD_AFTER
  end

  def expire_password!
    new_password = SecureRandom.hex(12)
    reset_password(new_password, new_password, store_password: false)
  end

  def reset_password(password, password_confirmation, store_password: true)
    return if store_password && password == password_confirmation && password_used?(password)
    return unless super(password, password_confirmation)
    return unless store_password
    update password_changed_at: Time.zone.now
    save_old_password
  end

  def password_used?(password)
    old_passwords.find_each do |old_password|
      if Devise::Encryptor.compare(self.class, old_password.encrypted_password, password)
        errors.add :password, 'has already been used'
        return true
      end
    end
  end

  def save_old_password
    old_passwords.create encrypted_password: encrypted_password
    old_passwords.order(id: :desc).offset(PASSWORD_ARCHIVE).destroy_all
  end
end
