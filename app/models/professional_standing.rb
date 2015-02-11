class ProfessionalStanding < ActiveRecord::Base
  default_scope { order(:order) }
end
