class Sheet < ActiveRecord::Base
  attr_accessible :description, :design_id, :name, :project_id, :study_date, :subject_id, :variable_ids

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ? or subject_id in (select subjects.id from subjects where subjects.deleted = ? and LOWER(subjects.subject_code) LIKE ?)', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', false, '%' + args.first.downcase.split(' ').join('%') + '%'  ] } }
  scope :sheet_before, lambda { |*args| { conditions: ["sheets.study_date < ?", (args.first+1.day)]} }
  scope :sheet_after, lambda { |*args| { conditions: ["sheets.study_date >= ?", args.first]} }
  scope :with_user, lambda { |*args| { conditions: ["sheets.user_id in (?)", args.first] } }
  scope :with_project, lambda { |*args| { conditions: ["sheets.project_id IN (?)", args.first] } }
  scope :with_design, lambda { |*args| { conditions: ["sheets.design_id IN (?)", args.first] } }
  scope :with_site, lambda { |*args| { conditions: ["sheets.subject_id IN (select subjects.id from subjects where subjects.deleted = ? and subjects.site_id IN (?))", false, args.first] } }

  scope :order_by_site, lambda { |*args| { joins: "LEFT JOIN subjects ON subjects.id = sheets.subject_id", order: 'subjects.site_id' } }
  scope :order_by_site_desc, lambda { |*args| { joins: "LEFT JOIN subjects ON subjects.id = sheets.subject_id", order: 'subjects.site_id DESC' } }

  # Model Validation
  validates_presence_of :design_id, :name, :project_id, :study_date, :subject_id, :user_id
  validates_uniqueness_of :study_date, scope: [:project_id, :subject_id, :design_id, :deleted]

  # Model Relationships
  belongs_to :user
  belongs_to :design
  belongs_to :project
  belongs_to :subject
  has_many :variables, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end

  def email_receipt(current_user, to, cc, subject, body)
    UserMailer.sheet_receipt(current_user, to, cc, subject, body).deliver #if Rails.env.production?
  end

  def email_body_template(current_user)
    %Q{Dear #{self.subject.site.name}:

On #{self.created_at.strftime("%m/%d/%Y")} I reviewed #{self.name} for #{self.subject.subject_code} collected on #{self.study_date.strftime("%m/%d/%Y")} and have some comments (see below).



Feel free to contact me if you have any questions.  Thank you.



  Participant ID:    #{self.subject.subject_code}

  Date of Study:    #{self.study_date.strftime("%m/%d/%Y")}

  Date Received:    #{self.created_at.strftime("%m/%d/%Y")}


#{self.variables.collect{|v| '  ' + v.name.to_s + ':  ' + v.response_name.to_s}.join("\n\n")}

  Comments:

Thanks,



#{current_user.name}
  }
  end

  def email_subject_template(current_user)
    "#{self.project.name} #{self.name} Receipt: #{self.subject.subject_code}"
  end
end
