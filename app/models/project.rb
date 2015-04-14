class Project < ActiveRecord::Base

  PER_PAGE = 40

  mount_uploader :logo, ImageUploader

  # Concerns
  include Searchable, Deletable

  attr_accessor :site_name

  after_save :create_default_site

  # Named Scopes
  scope :with_user, lambda { |arg| where(user_id: arg) }
  scope :with_editor, lambda { |*args| where('projects.user_id = ? or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.editor IN (?))', args.first, args.first, args[1] ).references(:project_users) }
  scope :by_favorite, lambda { |arg| joins("LEFT JOIN project_favorites ON project_favorites.project_id = projects.id and project_favorites.user_id = #{arg.to_i}").references(:project_favorites) }

  # Model Validation
  validates_presence_of :name, :user_id
  validates_uniqueness_of :slug, scope: [ :deleted ], allow_blank: true
  validates_format_of :slug, with: /\A[a-z][a-z0-9\-]*\Z/, allow_blank: true

  # Model Relationships
  belongs_to :user

  has_many :project_users
  has_many :users, -> { where( deleted: false ).order( 'last_name, first_name' ) }, through: :project_users
  has_many :editors, -> { where('project_users.editor = ? and users.deleted = ?', true, false) }, through: :project_users, source: :user
  has_many :viewers, -> { where('project_users.editor = ? and users.deleted = ?', false, false) }, through: :project_users, source: :user

  has_many :project_favorites

  has_many :designs, -> { where deleted: false }
  has_many :variables, -> { where deleted: false }
  has_many :schedules, -> { where deleted: false }
  has_many :sheets, -> { where deleted: false }
  has_many :sites, -> { where deleted: false }
  has_many :subjects, -> { where deleted: false }

  has_many :exports, -> { where deleted: false }
  has_many :events, -> { where deleted: false }

  has_many :contacts, -> { where deleted: false }
  has_many :documents, -> { where deleted: false }
  has_many :posts, -> { where deleted: false }
  has_many :links, -> { where deleted: false }

  has_many :domains, -> { where deleted: false }

  # Model Methods

  def to_param
    slug.blank? ? id : slug
  end

  def self.find_by_param(input)
    self.where("slug = ? or id = ?", input.to_s, input.to_i).first
  end

  def recent_sheets
    self.sheets.with_subject_status('valid').where("created_at > ?", (Time.now.monday? ? Time.now - 3.day : Time.now - 1.day))
  end

  # Project Owners and Project Editors
  def editable_by?(current_user)
    @editable_by ||= begin
      current_user.all_projects.where(id: self.id).count == 1
    end
  end

  # Project Owners
  def deletable_by?(current_user)
    current_user.projects.where( id: self.id ).count == 1
  end

  def can_edit_sheets_and_subjects?(current_user)
    current_user.all_sheet_editable_projects.where( id: self.id ).count == 1
  end

  def sites_with_range
    self.sites.where("sites.code_minimum IS NOT NULL and sites.code_minimum != '' and sites.code_maximum IS NOT NULL and sites.code_maximum != ''").order('name')
  end

  def site_id_with_prefix(prefix)
    prefix_sites = self.sites.select{|s| not s.prefix.blank? and prefix.start_with?(s.prefix) }
    prefix_sites.size == 1 ? prefix_sites.first.id : nil
  end

  def subject_code_name_full
    self.subject_code_name.to_s.strip.blank? ? 'Subject Code' : self.subject_code_name.to_s.strip
  end

  def users_to_email
    result = (self.users + [self.user] + self.sites.collect{|s| s.users}.flatten).uniq
    result = result.select{ |u| u.email_on?(:send_email) }
  end

  # Returns "fake" constructed variables like 'site' and 'sheet_date'
  def variable_by_id(variable_id)
    if variable_id == 'design'
      Variable.design(self.id)
    elsif variable_id == 'site'
      Variable.site(self.id)
    elsif variable_id == 'sheet_date'
      Variable.sheet_date(self.id)
    else
      self.variables.find_by_id(variable_id)
    end
  end

  def create_valid_subject(email, site_id)
    self.create_default_site if self.sites.count == 0
    hexdigest = Digest::SHA1.hexdigest(Time.now.usec.to_s)

    site_id = self.sites.first.id unless site = self.sites.find_by_id(site_id)

    if email.blank?
      subject_code = hexdigest[0..12]
    elsif self.subjects.where( subject_code: email.to_s ).size == 0
      subject_code = email.to_s
    else
      subject_code = "#{email.to_s} - #{hexdigest[0..8]}"
    end
    self.subjects.create( subject_code: subject_code, user_id: self.user_id, site_id: site_id, status: 'valid', acrostic: '', email: email.to_s )
  end

  def favorited_by?(current_user)
    project_favorite = self.project_favorites.find_by_user_id(current_user.id)
    not project_favorite.blank? and project_favorite.favorite?
  end

  def archived_by?(current_user)
    if project_favorite = self.project_favorites.find_by_user_id(current_user.id)
      project_favorite.archived?
    else
      false
    end
  end

  def create_design_from_json(design_json, current_user)
    options = self.create_options_from_json(design_json['options'], current_user)
    description = design_json['description'].to_s.strip
    name = design_json['name'].to_s.strip
    self.designs.where( name: name ).first_or_create( description: description, user_id: current_user.id, options: options )
  end

  def create_options_from_json(options_json, current_user)
    options = []
    options_json.each do |option_json|
      option = {}
      if not option_json['variable'].blank?
        variable = self.create_variable_from_json(option_json['variable'], current_user)
        if variable
          option[:variable_id] = variable.id
          option[:branching_logic] = option_json['branching_logic'].to_s.strip
        end
      elsif not option_json['section_name'].blank?
        option[:section_name] = option_json['section_name'].to_s.strip
        option[:section_id] = option_json['section_id'].to_s.strip
        option[:section_description] = option_json['section_description'].to_s.strip
        option[:section_type] = option_json['section_type'].to_i
        option[:branching_logic] = option_json['branching_logic'].to_s.strip
      end
      options << option unless option.blank?
    end
    options
  end

  def create_variable_from_json(variable_json, current_user)
    domain = self.create_domain_from_json(variable_json['domain'], current_user) unless variable_json['domain'].blank?
    grid_variables = self.create_grid_variables_from_json(variable_json['grid_variables'], current_user) unless variable_json['grid_variables'].blank?
    name = variable_json['name']
    keys = [ :display_name, :description, :variable_type, :display_name_visibility, :prepend, :append,
      # For Integers and Numerics
      :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum,
      # For Dates
      :date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum,
      # For Date, Time
      :show_current_button,
      # For Calculated Variables
      :calculation, :format,
      # For Integer, Numeric, and Calculated
      :units,
      # For Grid Variables
      :multiple_rows, :default_row_number,
      # For Autocomplete Strings
      :autocomplete_values,
      # Radio and Checkbox
      :alignment
    ]
    hash = {}
    keys.each do |key|
      hash[key] = variable_json[key.to_s].to_s.strip
    end
    hash[:domain_id] = domain.id if domain
    hash[:grid_variables] = grid_variables if grid_variables
    hash[:user_id] = current_user.id
    variable = self.variables.where( name: name ).first_or_create( hash )
  end

  def create_domain_from_json(domain_json, current_user)
    name = domain_json['name'].to_s.strip

    display_name = domain_json['display_name'].to_s.strip
    description = domain_json['description'].to_s.strip
    options = domain_json['options'].collect{|hash| hash.symbolize_keys }

    self.domains.where( name: name ).first_or_create( display_name: display_name, description: description, options: options, user_id: current_user.id )
  end

  def create_grid_variables_from_json(grid_variables_json, current_user)
    grid_variables = []
    grid_variables_json.each do |grid_variable_json|
      variable = self.create_variable_from_json(grid_variable_json, current_user)
      grid_variables << { variable_id: variable.id } if variable
    end
    grid_variables
  end

  def show_type
    self.hide_values_on_pdfs? ? :display_name : :name
  end

  private

    # Creates a default site if the project has no site associated with it
    def create_default_site
      if self.sites.count == 0
        self.sites.create(
          name: self.site_name.blank? ? "Default Site" : self.site_name,
          user_id: self.user_id,
          prefix: ''
        )
      end
    end

end
