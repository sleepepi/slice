# frozen_string_literal: true

# Tracks a set of audits in a single transaction.
class SheetTransaction < ApplicationRecord
  # Constants
  TRANSACTION_TYPE = %w(
    sheet_create sheet_update
    public_sheet_create public_sheet_update
    api_sheet_create api_sheet_update
  )

  # Relationships
  belongs_to :project
  belongs_to :sheet
  belongs_to :user, optional: true
  has_many :sheet_transaction_audits, -> { order :id }

  # Methods

  # This modifies existing values the sheet with new unsaved values for
  # validation. None of these changes are saved to the database.
  def self.validate_variable_values(sheet, variables_params, partial_validation)
    in_memory_sheet = Validation::InMemorySheet.new(sheet, partial_validation: partial_validation)
    in_memory_sheet.merge_form_params!(variables_params)
    in_memory_sheet.valid?
    in_memory_sheet.errors.each do |variable_name, error_message|
      sheet.errors.add(variable_name.to_sym, error_message)
    end
    sheet.errors.count.zero?
  end

  def self.save_sheet!(sheet, sheet_params, variables_params, current_user, remote_ip, transaction_type, skip_validation: false, skip_callbacks: false, partial_validation: false)
    return false unless skip_validation || validate_variable_values(sheet, variables_params, partial_validation)
    (sheet_save_result, original_attributes) = save_or_update_sheet!(sheet, sheet_params, transaction_type)
    if sheet_save_result
      sheet_transaction = create(
        transaction_type: transaction_type,
        project_id: sheet.project_id,
        sheet_id: sheet.id,
        user: current_user,
        remote_ip: remote_ip,
        language_code: World.language
      )
      sheet_transaction.generate_audits!(original_attributes)
      sheet_transaction.update_variables!(variables_params, current_user)
      unless skip_callbacks
        sheet.update_coverage!
        sheet.update_uploaded_file_counts!
        sheet.subject.update_uploaded_file_counts!
        sheet.update_associated_subject_events!
      end
      unless skip_validation
        sheet.create_notifications! if %w(sheet_create public_sheet_create api_sheet_create).include?(transaction_type)
      end
    end
    sheet_save_result
  end

  def self.save_or_update_sheet!(sheet, sheet_params, transaction_type)
    sheet_save_result = \
      case transaction_type
      when "sheet_create", "public_sheet_create", "api_sheet_create"
        sheet.initial_language_code = World.language
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
    when "grid"
      update_grid_responses!(sv, response, current_user)
    else
      update_response_with_transaction(sv, response, current_user)
    end
  end

  # {"-1"=>{"-1"=>""}, # This parameter clears the grid if all other rows are removed, similar to passing a "0" for a fallback value for empty checkboxes.
  #  "13463487147483201"=>{"123"=>"6", "494"=>["", "1", "0"], "493"=>"This is my institution"},
  #  "1346351022118849"=>{"123"=>"1", "494"=>[""], "493"=>""},
  #  "1346351034600475"=>{"494"=>["", "0"], "493"=>""}}
  def update_grid_responses!(sheet_variable, response, current_user)
    response.select! do |_key, vhash|
      vhash.values.count { |v| (!v.is_a?(Array) && v.present?) || (v.is_a?(Array) && v.join.present?) }.positive?
    end
    position = 0
    response.each_pair do |_key, variable_response_hash|
      variable_response_hash.each_pair do |variable_id, res|
        grid = sheet_variable.grids
                             .where(variable_id: variable_id, position: position)
                             .first_or_create(user: current_user)
        if grid.variable.variable_type == "file"
          grid_old = sheet_variable.grids.find_by(variable_id: variable_id, position: key)
          if !res[:response_file].is_a?(Hash) || res[:remove_response_file] == "1" || res[:response_file_cache].present?
            # New file added, do nothing
          elsif grid_old
            # Found preexisting grid
            # copy from existing grid
            res = { response_file: grid_old.response_file }
          else
            # No old grid found, remove file
            res = { remove_response_file: "1" }
          end
        end
        update_response_with_transaction(grid, res, current_user)
      end
      position += 1
    end
    sheet_variable.grids.where("position >= ?", response.keys.size).destroy_all
  end

  def update_response_with_transaction(object, value, current_user)
    slicer = Slicers.for(object.variable, sheet: sheet, current_user: current_user, object: object)
    slicer.pre_audit
    save_result = slicer.save(value)
    slicer.record_audit(sheet_transaction: self)
    save_result
  end
end
