class AeModule::ManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect

  def dashboard
  end
end
