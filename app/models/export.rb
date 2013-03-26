class Export < ActiveRecord::Base

  after_create :calculate_total_steps

  mount_uploader :file, GenericUploader

  STATUS = ["ready", "pending", "failed"].collect{|i| [i,i]}

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where("LOWER(exports.name) LIKE ?", arg.to_s.downcase.gsub(/^| |$/, '%')) }

  # Model Validation
  validates_presence_of :name, :user_id, :project_id

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods
  def notify_user!
    UserMailer.export_ready(self).deliver if Rails.env.production?
  end

  def self.filter(filters)
    scope = self.all
    filters.each_pair do |key, value|
      scope = scope.where(key => value) if self.column_names.include?(key.to_s) and not value.blank?
    end
    scope
  end

  private

    def calculate_total_steps
      steps = 0
      steps += sheet_ids_count if self.include_xls?
      steps += sheet_ids_count if self.include_csv_labeled?
      steps += sheet_ids_count if self.include_csv_labeled?
      steps += sheet_ids_count if self.include_csv_raw? or self.include_sas?
      steps += sheet_ids_count if self.include_csv_raw? or self.include_sas?
      steps += sheet_ids_count if self.include_pdf?
      steps += sheet_ids_count if self.include_data_dictionary?
      steps += sheet_ids_count if self.include_sas?
      steps += sheet_ids_count if self.include_files?
      self.update_column :total_steps, steps
    end

end
