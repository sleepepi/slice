# frozen_string_literal: true

class SheetTransaction < ApplicationRecord
  TRANSACTION_TYPE = ["sheet_create", "sheet_update", "public_sheet_create", "public_sheet_update", "domain_update", "sheet_rollback"]

  # Model Relationships
  belongs_to :project
  belongs_to :sheet
  belongs_to :user
  has_many :sheet_transaction_audits, -> { order :id }

  # Model Methods

  # This modifies existing values the sheet with new unsaved values for
  # validation. None of these changes are saved to the database.
  def self.validate_variable_values(sheet, variables_params)
    in_memory_sheet = Validation::InMemorySheet.new(sheet)
    in_memory_sheet.merge_form_params!(variables_params)
    in_memory_sheet.valid?
    in_memory_sheet.errors.each do |error|
      sheet.errors.add(:base, error)
    end
    return sheet.errors.count == 0
  end

  def self.save_sheet!(sheet, sheet_params, variables_params, current_user, remote_ip, transaction_type, skip_validation: false)
    return false unless skip_validation || validate_variable_values(sheet, variables_params)

    sheet_save_result = case transaction_type
                        when 'sheet_create', 'public_sheet_create'
                          sheet.save
                        else
                          sheet.update(sheet_params)
                        end

    ignore_attributes = %w(created_at updated_at authentication_token deleted successfully_validated)

    original_attributes = sheet.previous_changes.collect { |k, v| [k, v[0]] }.reject { |k, _v| ignore_attributes.include?(k.to_s) }

    if sheet_save_result
      sheet_transaction = create(transaction_type: transaction_type, project_id: sheet.project_id, sheet_id: sheet.id, user_id: (current_user ? current_user.id : nil), remote_ip: remote_ip)
      sheet_transaction.generate_audits!(original_attributes)
      sheet_transaction.update_variables!(variables_params, current_user)
    end

    sheet_save_result
  end

  def generate_audits!(original_attributes)
    original_attributes.each do |trackable_attribute, old_value|
      value_before = (old_value == nil ? nil : old_value.to_s)
      value_after = (self.sheet.send(trackable_attribute) == nil ? nil : self.sheet.send(trackable_attribute).to_s)
      if value_before != value_after
        self.sheet_transaction_audits.create( sheet_attribute_name: trackable_attribute.to_s, value_before: value_before, value_after: value_after, label_before: nil, label_after: nil, value_for_file: false, project_id: self.project_id, sheet_id: self.sheet_id, user_id: self.user_id )
      end
    end
  end

  def update_variables!(variables_params, current_user)
    variables_params.each_pair do |variable_id, response|
      # value_before = nil
      # value_after = nil
      # value_for_file = false
      # sheet_variable_id = nil
      # attribute_name = nil
      sv = sheet.sheet_variables
                .where(variable_id: variable_id)
                .first_or_create(user_id: (current_user ? current_user.id : nil))
      case sv.variable.variable_type
      when 'grid'
        update_grid_responses!(sv, response, current_user)
      else
        update_response_with_transaction(sv, response, current_user)
      end
    end
    sheet.update_response_count!
  end

  def update_grid_responses!(sheet_variable, response, current_user)
    # {"13463487147483201"=>{"123"=>"6", "494"=>["", "1", "0"], "493"=>"This is my institution"},
    #  "1346351022118849"=>{"123"=>"1", "494"=>[""], "493"=>""},
    #  "1346351034600475"=>{"494"=>["", "0"], "493"=>""}}
    response.select! do |_key, vhash|
      vhash.values.count { |v| (!v.is_a?(Array) && v.present?) || (v.is_a?(Array) && v.join.present?) } > 0
    end
    response.each_pair { |k, v| }.each.with_index do |(key, variable_response_hash), position|
      variable_response_hash.each_pair do |variable_id, res|
        grid = sheet_variable.grids
                             .where(variable_id: variable_id, position: position)
                             .first_or_create(user_id: (current_user ? current_user.id : nil))
        if grid.variable.variable_type == 'file'
          grid_old = sheet_variable.grids.find_by_variable_id_and_position(variable_id, key)
          if !res[:response_file].is_a?(Hash) || res[:remove_response_file] == '1' || res[:response_file_cache].present?
            # New file added, do nothing
          elsif grid_old
            # Found preexisting grid
            # copy from existing grid
            res = { response_file: grid_old.response_file }
          else
            # No old grid found, remove file
            res = { remove_response_file: '1' }
          end
        end

        self.update_response_with_transaction(grid, res, current_user)
      end
    end

    sheet_variable.grids.where('position >= ?', response.keys.size).destroy_all
  end

  def update_response_with_transaction(object, response, current_user)
    sheet_variable_id = nil
    grid_id = nil

    value_before = object.get_response(:raw).to_s
    label_before = object.get_response(:name).to_s

    if object.variable.variable_type == 'checkbox'
      response = [] if response.blank?
      object.update_responses!(response, current_user, sheet) # Response should be an array
    else
      object.update_attributes object.format_response(object.variable.variable_type, response)
    end

    value_after = object.get_response(:raw).to_s
    label_after = object.get_response(:name).to_s
    value_for_file = (object.variable.variable_type == 'file')
    if object.class == SheetVariable
      sheet_variable_id = object.id
    elsif object.class == Grid
      grid_id = object.id
      sheet_variable_id = object.sheet_variable.id
    end

    if value_before != value_after
      sheet_transaction_audits.create(
        value_before: value_before, value_after: value_after,
        label_before: label_before, label_after: label_after,
        value_for_file: value_for_file, project_id: project_id,
        sheet_id: sheet_id, user_id: user_id,
        sheet_variable_id: sheet_variable_id, grid_id: grid_id
      )
    end
  end
end
