# Temporary class that will be used to migrate old audits into new transaction system
class Audit < ActiveRecord::Base

  serialize :audited_changes

  belongs_to :user

end
