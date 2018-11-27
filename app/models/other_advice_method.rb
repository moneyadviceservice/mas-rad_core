class OtherAdviceMethod < ActiveRecord::Base
  include Translatable
  include FriendlyNamable
  include SystemNameable

  SYSTEM_NAMES = {
    1 => :phone,
    2 => :online
  }

  has_and_belongs_to_many :firms

  validates_presence_of :name

  default_scope { order(:order) }
end
