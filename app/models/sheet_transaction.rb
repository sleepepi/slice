# frozen_string_literal: true

# Tracks a set of audits in a single transaction.
class SheetTransaction < ApplicationRecord
  TRANSACTION_TYPE = %w(sheet_create sheet_update public_sheet_create public_sheet_update)

  # Relationships
  belongs_to :project
  belongs_to :sheet
  belongs_to :user
  has_many :sheet_transaction_audits, -> { order :id }

  # Methods

  # This modifies existing values the sheet with new unsaved values for
  # validation. None of these changes are saved to the database.
  def self.validate_variable_values(sheet, variables_params)
    in_memory_sheet = Validation::InMemorySheet.new(sheet)
    in_memory_sheet.merge_form_params!(variables_params)
    in_memory_sheet.valid?
    in_memory_sheet.errors.each do |error|
      sheet.errors.add(:base, error)
    end
    sheet.errors.count.zero?
  end

  def self.save_sheet!(sheet, sheet_params, variables_params, current_user, remote_ip, transaction_type, skip_validation: false, skip_callbacks: false)
    return false unless skip_validation || validate_variable_values(sheet, variables_params)
    (sheet_save_result, original_attributes) = save_or_update_sheet!(sheet, sheet_params, transaction_type)
    if sheet_save_result
      sheet_transaction = create(
        transaction_type: transaction_type,
        project_id: sheet.project_id,
        sheet_id: sheet.id,
        user: current_user,
        remote_ip: remote_ip
      )
      sheet_transaction.generate_audits!(original_attributes)
      sheet_transaction.update_variables!(variables_params, current_user)
      unless skip_callbacks
        sheet.update_response_count!
        sheet.subject.update_uploaded_file_counts!
      end
      unless skip_validation
        sheet.subject.reset_checks_in_background!
        sheet.create_notifications! if %w(sheet_create public_sheet_create).include?(transaction_type)
      end
    end
    sheet_save_result
  end

  def self.save_or_update_sheet!(sheet, sheet_params, transaction_type)
    sheet_save_result = \
      case transaction_type
      when 'sheet_create', 'public_sheet_create'
        sheet.save
      else
        sheet.update(sheet_params)
      end
    [sheet_save_result, sheet.original_attributes]
  end

  def generate_audits!(original_attributes)
    original_attributes.each do |trackable_attribute, old_value|
      value_before = (old_value.nil? ? nil : old_value.to_s)
      value_after = (sheet.send(trackable_attribute).nil? ? nil : sheet.send(trackable_attribute).to_s)
      next if value_before == value_after
      sheet_transaction_audits.create(
        project_id: project_id, user_id: user_id, sheet_id: sheet_id,
        sheet_attribute_name: trackable_attribute.to_s,
        value_before: value_before, value_after: value_after
      )
    end
  end

  def update_variables!(variables_params, current_user)
    variables_params.each_pair do |variable_id, response|
      sv = sheet.sheet_variables
                .where(variable_id: variable_id)
                .first_or_create(user: current_user)
      update_sheet_variable_response!(sv, response, current_user)
    end
  end

  def update_sheet_variable_response!(sv, response, current_user)
    case sv.variable.variable_type
    when 'grid'
      update_grid_responses!(sv, response, current_user)
    else
      update_response_with_transaction(sv, response, current_user)
    end
  end

  # {"13463487147483201"=>{"123"=>"6", "494"=>["", "1", "0"], "493"=>"This is my institution"},
  #  "1346351022118849"=>{"123"=>"1", "494"=>[""], "493"=>""},
  #  "1346351034600475"=>{"494"=>["", "0"], "493"=>""}}
  def update_grid_responses!(sheet_variable, response, current_user)
    response.select! do |_key, vhash|
      vhash.values.count { |v| (!v.is_a?(Array) && v.present?) || (v.is_a?(Array) && v.join.present?) } > 0
    end
    response.each_pair { |k, v| }.each.with_index do |(key, variable_response_hash), position|
      variable_response_hash.each_pair do |variable_id, res|
        grid = sheet_variable.grids
                             .where(variable_id: variable_id, position: position)
                             .first_or_create(user: current_user)
        if grid.variable.variable_type == 'file'
          grid_old = sheet_variable.grids.find_by(variable_id: variable_id, position: key)
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
        update_response_with_transaction(grid, res, current_user)
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
      object.update(object.format_response(response))
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
    return if value_before == value_after
    sheet_transaction_audits.create(
      value_before: value_before, value_after: value_after,
      label_before: label_before, label_after: label_after,
      value_for_file: value_for_file, project_id: project_id,
      sheet_id: sheet_id, user_id: user_id,
      sheet_variable_id: sheet_variable_id, grid_id: grid_id
    )
  end
end
