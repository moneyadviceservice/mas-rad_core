class InitialMeetingDuration < ActiveRecord::Base
  has_many :firms

  validates_presence_of :name

  default_scope { order(:order) }
end
