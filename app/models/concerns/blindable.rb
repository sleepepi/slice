# frozen_string_literal: true

# Provides scope for models that need to be filtered when project blinding is
# enabled.
module Blindable
  extend ActiveSupport::Concern

  included do
    # Shows model IF
    # User is Project Owner
    # OR User is Unblinded Project Member
    # OR User is Unblinded Site Member
    # OR Project has Blind module disabled
    # OR model not set as Only Blinded
    def self.blinding_scope(user)
      joins(:project)
        .joins("LEFT OUTER JOIN project_users ON project_users.project_id = projects.id and project_users.user_id = #{user.id}")
        .joins("LEFT OUTER JOIN site_users ON site_users.project_id = projects.id and site_users.user_id = #{user.id}")
        .blinding_scope_where(user)
        .distinct
    end

    def self.blinding_scope_where(user)
      if column_names.include?('only_unblinded')
        where("projects.user_id = ? or project_users.unblinded = ? or site_users.unblinded = ? or projects.blinding_enabled = ? or #{table_name}.only_unblinded = ?", user.id, true, true, false, false)
      else
        where('projects.user_id = ? or project_users.unblinded = ? or site_users.unblinded = ? or projects.blinding_enabled = ?', user.id, true, true, false)
      end
    end
  end
end
