class AeModuleController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect

  def dashboard
  end

  private

  # def find_viewable_project_or_redirect
  #   super(:id)
  # end
end
