class Accreditation < ActiveRecord::Base
  include FriendlyNamable

  validates_presence_of :name

  default_scope { order(:order) }
end
