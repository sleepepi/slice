class SheetVariable < ActiveRecord::Base
  attr_accessible :response, :sheet_id, :user_id, :variable_id, :response_file, :response_file_uploaded_at, :response_file_cache

  belongs_to :sheet, touch: true
  belongs_to :variable
  belongs_to :user

  has_many :grids

  validates_presence_of :sheet_id, :variable_id, :user_id

  mount_uploader :response_file, GenericUploader



  def update_grid_responses!(response)
    # {"13463487147483201"=>{"123"=>"6", "494"=>["", "1", "0"], "493"=>"This is my institution"},
    #  "1346351022118849"=>{"123"=>"1", "494"=>[""], "493"=>""},
    #  "1346351034600475"=>{"494"=>["", "0"], "493"=>""}}
    response.each_with_index do |(key, variable_response_hash), position|
      variable_response_hash.each_pair do |variable_id, res|
        grid = self.grids.find_or_create_by_variable_id_and_position(variable_id, position, { user_id: self.user_id })
        grid.update_attributes format_response(grid.variable.variable_type, res)
      end
    end

    self.grids.where("position >= ?", response.size).destroy_all
  end

  # Returns response as a hash that can sent to update_attributes
  def format_response(variable_type, response)
    case variable_type when 'file'
      response = {} if response.blank?
    when 'checkbox'
      response = [] if response.blank?
      response = { response: response }
    when 'date'
      response = { response: parse_date(response, response) }
    when 'time'
      response = { response: parse_time(response) } # Currently things that aren't parsed are stored as blank.
    else
      response = { response: response }
    end
    response
  end

  private

  # Copied from Application Controller
  def parse_date(date_string, default_date = '')
    date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue default_date
  end

  # Copied from Application Controller
  def parse_time(time_string, default_time = '')
    Time.parse(time_string).strftime('%H:%M:%S') rescue default_time
  end


end
