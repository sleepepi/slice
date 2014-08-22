class SheetVariable < ActiveRecord::Base
  # attr_accessible :response, :sheet_id, :user_id, :variable_id, :response_file, :response_file_uploaded_at, :response_file_cache, :remove_response_file

  # Concerns
  include Valuable

  # Model Validation
  validates_presence_of :sheet_id

  # Model Relationships
  belongs_to :sheet, touch: true
  belongs_to :user
  has_many :grids


  def max_grids_position
    self.variable.variable_type == 'grid' && self.grids.size > 0 ? self.grids.pluck(:position).max : -1
  end

  # Returns it's ID if it's not empty, else nil
  def empty_or_not
    if self.responses.count > 0 or self.grids.count > 0 or not self.response.blank? or not self.response_file.blank?
      self.id
    else
      nil
    end
  end

end
