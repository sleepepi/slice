# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :authenticate_user!

  layout "layouts/full_page_sidebar"

  # # GET /settings/profile
  # def profile
  # end

  # PATCH /settings/profile
  def update_profile
    if current_user.update(profile_params)
      redirect_to settings_profile_path, notice: "Profile successfully updated."
    else
      render :profile
    end
  end

  # PATCH /settings/profile/picture
  def update_profile_picture
    if current_user.update(profile_picture_params)
      redirect_to settings_profile_path, notice: "Profile picture successfully updated."
    else
      render :profile
    end
  end

  # # GET /settings/account
  # def account
  # end

  # PATCH /settings/account
  def update_account
    if current_user.update(account_params)
      redirect_to settings_account_path, notice: "Account successfully updated."
    else
      render :account
    end
  end

  # PATCH /settings/password
  def update_password
    if current_user.valid_password?(params[:user][:current_password])
      if current_user.reset_password(params[:user][:password], params[:user][:password_confirmation])
        bypass_sign_in current_user
        redirect_to settings_account_path, notice: "Your password has been changed."
      else
        render :account
      end
    else
      current_user.errors.add(:current_password, "is invalid")
      render :account
    end
  end

  # # GET /settings/email
  # def email
  # end

  # PATCH /settings/email
  def update_email
    if current_user.update(email_params)
      redirect_to settings_email_path, notice: "Email successfully updated." # I18n.t("devise.confirmations.send_instructions")
    else
      render :email
    end
  end

  # # GET /settings/interface
  # def interface
  # end

  # PATCH /settings/interface
  def update_interface
    if current_user.update(interface_params)
      redirect_to settings_interface_path, notice: "Settings successfully updated."
    else
      render :interface
    end
  end

  # # GET /settings/notifications
  # def notifications
  # end

  # PATCH /settings/notifications
  def update_notifications
    if current_user.update(notifications_params)
      redirect_to settings_notifications_path, notice: "Settings successfully updated."
    else
      render :notifications
    end
  end

  private

  def profile_params
    params.require(:user).permit(:username, :description)
  end

  def profile_picture_params
    params.require(:user).permit(:profile_picture, :remove_profile_picture)
  end

  def account_params
    params.require(:user).permit(:full_name)
  end

  def email_params
    params.require(:user).permit(:email)
  end

  def interface_params
    params.require(:user).permit(:theme, :sound_enabled)
  end

  def notifications_params
    params.require(:user).permit(:emails_enabled)
  end
end
