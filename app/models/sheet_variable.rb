require 'audited'
require 'audited/adapters/active_record'

class SheetVariable < ActiveRecord::Base
  # attr_accessible :response, :sheet_id, :user_id, :variable_id, :response_file, :response_file_uploaded_at, :response_file_cache, :remove_response_file

  audited associated_with: :sheet
  has_associated_audits

  # Concerns
  include Valuable, DateAndTimeParser

  # Model Validation
  validates_presence_of :sheet_id, :user_id

  # Model Relationships
  belongs_to :sheet, touch: true
  belongs_to :user
  has_many :grids


  def max_grids_position
    self.variable.variable_type == 'grid' && self.grids.size > 0 ? self.grids.pluck(:position).max : -1
  end

  def update_grid_responses!(response, current_user)
    # {"13463487147483201"=>{"123"=>"6", "494"=>["", "1", "0"], "493"=>"This is my institution"},
    #  "1346351022118849"=>{"123"=>"1", "494"=>[""], "493"=>""},
    #  "1346351034600475"=>{"494"=>["", "0"], "493"=>""}}
    response.select!{|key, vhash| vhash.values.select{|v| (not v.kind_of?(Array) and not v.blank?) or (v.kind_of?(Array) and not v.join.blank?)}.size > 0}
    response.each_with_index do |(key, variable_response_hash), position|
      variable_response_hash.each_pair do |variable_id, res|
        grid = self.grids.where( variable_id: variable_id, position: position ).first_or_create( user_id: self.user_id )
        if grid.variable.variable_type == 'file'
          grid_old = self.grids.find_by_variable_id_and_position(variable_id, key)
          if not res[:response_file].kind_of?(Hash) or res[:remove_response_file] == '1' or (res[:response_file].kind_of?(Hash) and not res[:response_file][:cache].blank?)
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

        case grid.variable.variable_type when 'checkbox'
          res = [] if res.blank?
          grid.update_responses!(res, current_user, self.sheet) # Response should be an array
        else
          grid.update_attributes format_response(grid.variable.variable_type, res)
        end

      end
    end

    self.grids.where("position >= ?", response.size).destroy_all
  end

  # Returns response as a hash that can sent to update_attributes
  def format_response(variable_type, response)
    case variable_type when 'file'
      response = {} if response.blank?
    when 'date'
      response = { response: parse_date(response, response) }
    when 'time'
      response = { response: parse_time(response) } # Currently things that aren't parsed are stored as blank.
    else
      response = { response: response }
    end
    response
  end

  # Returns it's ID if it's not empty, else nil
  def empty_or_not
    if self.responses.count > 0 or self.grids.count > 0 or not self.response.blank?
      self.id
    else
      nil
    end
  end

end
