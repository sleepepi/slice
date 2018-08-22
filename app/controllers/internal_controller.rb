# frozen_string_literal: true

# Allows users to stay signed in if their session will time out soon.
class InternalController < ApplicationController
  before_action :authenticate_user!

  # # POST /keep-me-active.js
  # def keep_me_active
  # end

  # GET /autocomplete
  def autocomplete
    @users = current_user.associated_users.search_any_order(params[:search]).order(:full_name).limit(10)
  end
end
