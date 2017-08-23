# frozen_string_literal: true

module Slicers
  # Provides default methods for checking variables and saving to database.
  class DefaultSlicer
    attr_accessor :value_was, :label_was, :value_is, :label_is

    def initialize(variable, sheet: nil, current_user: nil, remote_ip: nil)
      @variable = variable
      @sheet = sheet
      @current_user = current_user
      @remote_ip = remote_ip
    end

    def format_for_db_update(value)
      { value: value }
    end

    def pre_audit
      @value_was = object.get_response(:raw).to_s
      @label_was = object.get_response(:name).to_s
    end

    def save(value)
      object.update(format_for_db_update(value))
    end

    def post_audit
      @value_is = object.get_response(:raw).to_s
      @label_is = object.get_response(:name).to_s
    end

    def record_audit(sheet_transaction: nil)
      post_audit
      return if @value_was == @value_is
      sheet_variable_id = nil
      grid_id = nil
      if object.is_a?(SheetVariable)
        sheet_variable_id = object.id
      elsif object.is_a?(Grid)
        grid_id = object.id
      end
      value_for_file = (@variable.variable_type == "file")
      sheet_transaction ||= create_sheet_transaction
      sheet_transaction.sheet_transaction_audits.create(
        value_before: @value_was, value_after: @value_is,
        label_before: @label_was, label_after: @label_is,
        value_for_file: value_for_file, project_id: @sheet.project_id,
        sheet_id: @sheet.id, user: @current_user,
        sheet_variable_id: sheet_variable_id, grid_id: grid_id
      )
    end

    def create_sheet_transaction
      @sheet.sheet_transactions.create(
        transaction_type: "api_sheet_update",
        sheet_id: @sheet.id,
        user_id: @current_user,
        remote_ip: @remote_ip,
        project_id: @sheet.project_id
      )
    end

    def object
      @object ||= begin
        @sheet.sheet_variables.where(variable: @variable).first_or_create(user: @current_user)
      end
    end
  end
end
