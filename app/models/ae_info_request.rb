# frozen_string_literal: true

# Represents a request for more information made by an Adverse Event Admin to
# the Adverse Event Reporter(s).
class AeInfoRequest < ApplicationRecord
  # Concerns
  include Forkable

  # Validations
  validates :comment, presence: true

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :user
  belongs_to :resolver, class_name: "User", foreign_key: "resolver_id", optional: true
  belongs_to :ae_team, optional: true

  # Methods
  def destroy
    AeLogEntryAttachment.where(
      attachment_type: self.class.to_s,
      attachment_id: id
    ).destroy_all
    super
  end

  def open!(current_user)
    ae_adverse_event.update sent_for_review_at: nil unless ae_team
    ae_adverse_event.ae_log_entries.create(
      project: project,
      ae_team: ae_team,
      user: current_user,
      entry_type: "ae_info_request_created",
      info_requests: [self]
    )
    email_info_request_opened_in_background!
    # TODO: Generate in app notifications for info request to "AE admins" or "reporters of AE"
  end

  def resolved?
    !resolved_at.nil?
  end

  def resolve!(current_user)
    update(resolved_at: Time.zone.now, resolver: current_user)
    ae_adverse_event.ae_log_entries.create(
      project: project,
      ae_team: ae_team,
      user: current_user,
      entry_type: "ae_info_request_resolved",
      info_requests: [self]
    )
    email_info_request_resolved_in_background!
    # TODO: Generate in app notifications for info request to "AE admins" or "info_request creator"
  end

  def email_info_request_opened_in_background!
    fork_process(:email_info_request_opened!)
  end

  def email_info_request_opened!
    return if !EMAILS_ENABLED || project.disable_all_emails?

    if ae_team
      # Information request is coming from AE team and is sent to AE admins
      project.ae_review_admins.each do |review_admin|
        AeAdverseEventMailer.info_request_opened(self, review_admin.user).deliver_now
      end
    else
      # Information request is coming from AE Admins and is sent to AE reporter
      AeAdverseEventMailer.info_request_opened(self, ae_adverse_event.user).deliver_now
    end
  end

  def email_info_request_resolved_in_background!
    fork_process(:email_info_request_resolved!)
  end

  def email_info_request_resolved!
    return if !EMAILS_ENABLED || project.disable_all_emails?

    AeAdverseEventMailer.info_request_resolved(self).deliver_now
  end
end
