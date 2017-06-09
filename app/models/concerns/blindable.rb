# frozen_string_literal: true

# Provides scope for models that need to be filtered when project blinding is
# enabled. Blindable shows the associated object if the user is the project
# owner, or if the user is an unblinded project member, or if the user is an
# unblinded site member, or if the project-level blinding module is disabled, or
# if the object is not set to be only visible to unblinded members.
module Blindable
  extend ActiveSupport::Concern

  included do
    def self.blinding_scope(user)
      joins(:project)
        .left_joins_team_member(:project_users, user)
        .left_joins_team_member(:site_users, user)
        .blinding_scope_where(user)
        .distinct
    end

    def self.left_joins_team_member(association_table, user)
      joins("LEFT OUTER JOIN #{association_table} "\
            "ON #{association_table}.project_id = projects.id "\
            "AND #{association_table}.user_id = #{user.id}")
    end

    def self.blinding_scope_where(user)
      conditions = [
        "projects.user_id = ?", "project_users.unblinded = ?",
        "site_users.unblinded = ?", "projects.blinding_enabled = ?"
      ]
      values = [user.id, true, true, false]
      if column_names.include?("only_unblinded")
        conditions << "#{table_name}.only_unblinded = ?"
        values << false
      end
      where(conditions.join(" or "), *values)
    end
  end
end
