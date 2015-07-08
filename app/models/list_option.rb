class ListOption < ActiveRecord::Base

  # Model Relationships
  belongs_to :option, class_name: 'StratificationFactorOption', foreign_key: 'option_id'
  belongs_to :list

end
