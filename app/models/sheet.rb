class Sheet < ActiveRecord::Base
  attr_accessible :design_id, :project_id, :study_date, :subject_id, :variable_ids, :last_user_id

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :search, lambda { |*args| { conditions: [ 'subject_id in (select subjects.id from subjects where subjects.deleted = ? and LOWER(subjects.subject_code) LIKE ?)', false, '%' + args.first.downcase.split(' ').join('%') + '%'  ] } }
  scope :sheet_before, lambda { |*args| { conditions: ["sheets.study_date < ?", (args.first+1.day)]} }
  scope :sheet_after, lambda { |*args| { conditions: ["sheets.study_date >= ?", args.first]} }
  scope :with_user, lambda { |*args| { conditions: ["sheets.user_id in (?)", args.first] } }
  scope :with_project, lambda { |*args| { conditions: ["sheets.project_id IN (?)", args.first] } }
  scope :with_design, lambda { |*args| { conditions: ["sheets.design_id IN (?)", args.first] } }
  scope :with_site, lambda { |*args| { conditions: ["sheets.subject_id IN (select subjects.id from subjects where subjects.deleted = ? and subjects.site_id IN (?))", false, args.first] } }

  scope :order_by_site, lambda { |*args| { joins: "LEFT JOIN subjects ON subjects.id = sheets.subject_id", order: 'subjects.site_id' } }
  scope :order_by_site_desc, lambda { |*args| { joins: "LEFT JOIN subjects ON subjects.id = sheets.subject_id", order: 'subjects.site_id DESC' } }

  # Model Validation
  validates_presence_of :design_id, :project_id, :study_date, :subject_id, :user_id, :last_user_id
  validates_uniqueness_of :study_date, scope: [:project_id, :subject_id, :design_id, :deleted]

  # Model Relationships
  belongs_to :user
  belongs_to :last_user, class_name: "User"
  belongs_to :design
  belongs_to :project
  belongs_to :subject
  has_many :sheet_variables
  has_many :variables, through: :sheet_variables, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_column :deleted, true
  end

  def name
    self.design.name
  end

  def description
    self.design.description
  end

  def email_receipt(current_user, to, cc, subject, body, attachment)
    UserMailer.sheet_receipt(current_user, to, cc, subject, body, "#{self.subject.subject_code.strip.gsub(/[^\w]/, '-')}_#{self.study_date.strftime("%Y-%m-%d")}_#{self.name.strip.gsub(/[^\w]/, '-')}.pdf", attachment).deliver if Rails.env.production?
  end

  def email_body_template(current_user)
    result = ''
    result = self.design.email_template.to_s.gsub(/\$\((.*?)\)(\.name|\.label|\.value)?/){|m| variable_replacement($1,$2)}
    result = result.gsub(/\#\(subject\)(\.acrostic)?/){|m| subject_replacement($1)}
    result = result.gsub(/\#\(site\)/){|m| site_replacement($1)}
    result = result.gsub(/\#\(date\)/){|m| date_replacement($1)}
    result
  end

  def variable_replacement(variable_name, display_name)
    variable = self.variables.find_by_name(variable_name)
    if variable and display_name.blank?
      variable.response_name(self)
    elsif variable and display_name == '.name'
      variable.display_name
    elsif variable and display_name == '.label'
      variable.response_label(self)
    elsif variable and display_name == '.value'
      variable.response_raw(self)
    else
      ''
    end
  end

  def subject_replacement(property)
    if property.blank?
      self.subject.subject_code
    elsif property == '.acrostic'
      self.subject.acrostic.to_s
    else
      ''
    end
  end

  def site_replacement(property)
    self.subject.site.name
  end

  def date_replacement(property)
    self.study_date
  end

#   def email_body_template(current_user)
#     %Q{Dear #{self.subject.site.name}:

# On #{self.created_at.strftime("%m/%d/%Y")} I reviewed #{self.name} for #{self.subject.subject_code} collected on #{self.study_date.strftime("%m/%d/%Y")} and have some comments (see below).



# Feel free to contact me if you have any questions.  Thank you.



#   Participant ID:    #{self.subject.subject_code}

#   Date of Study:    #{self.study_date.strftime("%m/%d/%Y")}

#   Date Received:    #{self.created_at.strftime("%m/%d/%Y")}


# #{self.email_body_template_options(current_user)}

#   Comments:

# Thanks,



# #{current_user.name}
#   }
#   end

  # def email_body_template_options(current_user)
  #   self.design.options.collect{|opt| (v = Variable.current.find_by_id(opt[:variable_id])) ? (v.header.blank? ? '' : " #{v.header}\n") + '  ' + v.name.to_s + ':  ' + v.response_name(self).to_s : "\n#{opt[:section_name]}"}.join("\n\n")
  # end

  def email_subject_template(current_user)
    "#{self.project.name} #{self.name} Receipt: #{self.subject.subject_code}"
  end
end
