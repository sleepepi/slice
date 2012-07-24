class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_system_admin, only: [:new, :create, :edit, :update, :destroy]

  def index
    unless current_user.system_admin? or params[:format] == 'json'
      redirect_to root_path, alert: "You do not have sufficient privileges to access that page."
      return
    end
    # current_user.update_attributes users_per_page: params[:users_per_page].to_i if params[:users_per_page].to_i >= 10 and params[:users_per_page].to_i <= 200
    user_scope = User.current
    @search_terms = (params[:search] || params[:q]).to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| user_scope = user_scope.search(search_term) }

    @order = scrub_order(User, params[:order], 'users.current_sign_in_at DESC')
    user_scope = user_scope.order(@order)

    @users = user_scope.page(params[:page]).per(20) # (current_user.users_per_page)
    respond_to do |format|
      format.html
      format.js
      format.json { render json: params[:q].to_s.split(',').collect{|u| (u.strip.downcase == 'me') ? {name: current_user.name, id: current_user.name} : {name: u.strip.titleize, id: u.strip.titleize}} + @users.collect{|u| {name: u.name, id: u.name}}}
    end
  end

  def show
    @user = User.current.find_by_id(params[:id])
    redirect_to users_path unless @user
  end

  # def new
  #   @user = User.new
  # end

  def edit
    @user = User.current.find_by_id(params[:id])
    redirect_to users_path unless @user
  end

  # # This is in registrations_controller.rb
  # def create
  # end

  def update
    @user = User.current.find_by_id(params[:id])
    if @user and @user.update_attributes(params[:user])
      original_status = @user.status
      @user.update_column :system_admin, params[:system_admin]
      @user.update_column :status, params[:status]
      UserMailer.status_activated(@user).deliver if Rails.env.production? and original_status != @user.status and @user.status = 'active'
      @user.update_column :librarian, params[:librarian]
      redirect_to @user, notice: 'User was successfully updated.'
    elsif @user
      render action: "edit"
    else
      redirect_to users_path
    end
  end

  def destroy
    @user = User.find_by_id(params[:id])
    @user.destroy if @user
    redirect_to users_path
  end
end
