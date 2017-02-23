# frozen_string_literal: true

# Provides authentication for single adverse event to medical monitor.
class AdverseEventController < ApplicationController
  prepend_before_action { request.env['devise.skip_timeout'] = true }
  skip_before_action :verify_authenticity_token
  before_action :find_adverse_event_or_redirect

  # GET /adverse-event/:authentication_token
  def show
    @adverse_event_review = @adverse_event.adverse_event_reviews.new
  end

  # POST /adverse-event/:authentication_token/review
  def review
    @adverse_event_review = @adverse_event.adverse_event_reviews.new(adverse_event_review_params)
    if @adverse_event_review.save
      redirect_to about_path, notice: 'Thank you for reviewing this adverse event.'
    else
      render :show
    end
  end

  private

  def adverse_event_review_params
    params.require(:adverse_event_review).permit(:name, :comment)
  end

  def find_adverse_event_or_redirect
    authenticate_adverse_event_from_token!
    redirect_to about_path, alert: 'Adverse event has been closed.' unless @adverse_event
  end

  def authenticate_adverse_event_from_token!
    (adverse_event, auth_token) = parse_auth_token
    # Devise.secure_compare is used to mitigate timing attacks.
    return unless adverse_event && Devise.secure_compare(adverse_event.authentication_token, auth_token)
    @adverse_event = adverse_event
    @project = @adverse_event.project
  end

  def parse_auth_token
    adverse_event_id = parse_adverse_event_id
    auth_token = params[:authentication_token].to_s.gsub(/^#{adverse_event_id}-/, '')
    adverse_event = adverse_event_id && AdverseEvent.current.where(closed: false).find_by(id: adverse_event_id)
    [adverse_event, auth_token]
  end

  def parse_adverse_event_id
    params[:authentication_token].to_s.split('-').first.to_s.gsub(/[^a-z0-9]/i, '')
  end
end
