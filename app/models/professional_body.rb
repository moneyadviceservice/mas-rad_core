class ProfessionalBody < ActiveRecord::Base
  default_scope { order(:order) }
end
