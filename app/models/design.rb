class Design < ActiveRecord::Base
  attr_accessible :description, :name, :options, :option_tokens, :project_id

  serialize :options, Array

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_user, lambda { |*args| { conditions: ['designs.user_id IN (?)', args.first] } }
  scope :with_project, lambda { |*args| { conditions: ['designs.project_id IN (?)', args.first] } }
  scope :with_project_or_global, lambda { |*args| { conditions: ['designs.project_id IN (?) or designs.project_id IS NULL', args.first] } }
  scope :with_user_or_global, lambda { |*args| { conditions: ['designs.user_id IN (?) or designs.project_id IS NULL', args.first] } }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of :name, :user_id
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :sheets, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end

  def name_with_project
    self.project ? "#{self.name} - #{self.project.name}" : "#{self.name} - Global"
  end

  def editable_by?(current_user)
    current_user.all_designs.pluck(:id).include?(self.id) or (current_user.librarian? and self.project_id.blank?)
  end

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'user_id', 'project_id', 'deleted', 'created_at', 'updated_at'].include?(key.to_s)}
  end

  # Check that user has selected an editable project  OR
  #            user is a librarian and project_id is blank
  def saveable?(current_user, params_project_id)
    result = (current_user.all_projects.pluck(:id).include?(params_project_id.to_i) or (current_user.librarian? and params_project_id.blank?))
    self.errors.add(:project_id, "can't be blank" ) unless result
    result
  end

  def option_tokens=(tokens)
    self.options = []
    tokens.each_pair do |key, option_hash|
      if option_hash[:section_name].blank?
        self.options << {
                          variable_id: option_hash[:variable_id],
                          condition_variable_id: option_hash[:condition_variable_id],
                          condition_value: option_hash[:condition_value].to_s.strip
                        } unless option_hash[:variable_id].blank?
      else
        self.options << {
                          section_name: option_hash[:section_name].strip,
                          section_id: "_" + option_hash[:section_name].strip.gsub(/[^\w]/,'_').downcase,
                          section_description: option_hash[:section_description].strip
                        }
      end
    end
  end

  # [{"location": "#varvar_145", "values": []}, {"location": "#varvar_145", "values": []}]
  def values_hash(variable)
    [{ location: self.condition_parent(variable), values: self.condition_value(variable) }].to_json
  end

  def condition_parent(variable)
    self.options.select{|item| item[:variable_id].to_i == variable.id }.collect{|item| "#varvar_#{item[:condition_variable_id]}"}.join(',')
  end

  def condition_value(variable)
    self.options.select{|item| item[:variable_id].to_i == variable.id }.collect{ |item| item[:condition_value].to_s.split(",") }.flatten
  end

  def variable_ids
    @variable_ids ||= begin
      self.options.collect{|option| option[:variable_id].to_i}
    end
  end

  def variables
    Variable.current.where(id: variable_ids).sort!{ |a, b| variable_ids.index(a.id) <=> variable_ids.index(b.id) }
  end
end
