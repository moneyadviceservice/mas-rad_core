class Firm < ActiveRecord::Base
  include Geocodable

  ADVICE_TYPES_ATTRIBUTES = [
    :retirement_income_products_flag,
    :pension_transfer_flag,
    :long_term_care_flag,
    :equity_release_flag,
    :inheritance_tax_and_estate_planning_flag,
    :wills_and_probate_flag,
    :other_flag
  ]

  scope :registered, -> { where.not(email_address: nil) }
  scope :sorted_by_registered_name, -> { order(:registered_name) }

  has_and_belongs_to_many :in_person_advice_methods
  has_and_belongs_to_many :other_advice_methods
  has_and_belongs_to_many :initial_advice_fee_structures
  has_and_belongs_to_many :ongoing_advice_fee_structures
  has_and_belongs_to_many :allowed_payment_methods
  has_and_belongs_to_many :investment_sizes

  belongs_to :initial_meeting_duration
  belongs_to :principal, primary_key: :fca_number, foreign_key: :fca_number
  belongs_to :parent, class_name: 'Firm'

  has_many :advisers, dependent: :destroy
  has_many :subsidiaries, class_name: 'Firm', foreign_key: :parent_id, dependent: :destroy
  has_many :trading_names, class_name: 'Firm', foreign_key: :parent_id, dependent: :destroy
  has_many :qualifications, -> { reorder('').uniq }, through: :advisers
  has_many :accreditations, -> { reorder('').uniq }, through: :advisers

  attr_accessor :percent_total

  before_validation :upcase_postcode

  validates :email_address,
    presence: true,
    length: { maximum: 50 },
    format: { with: /.+@.+\..+/ }

  validates :telephone_number,
    presence: true,
    length: { maximum: 30 },
    format: { with: /\A[0-9 ]+\z/ }

  validates :website_address,
    allow_blank: true,
    length: { maximum: 100 },
    format: { with: /\Ahttps?:\/\/\S+\.\S+/ }

  validates :address_line_one,
    presence: true,
    length: { maximum: 100 }

  validates :address_line_two,
    length: { maximum: 100 }

  validates :address_postcode,
    presence: true,
    format: { with: /\A[A-Z\d]{1,4} [A-Z\d]{1,3}\z/ }

  validates :address_town,
    :address_county,
    presence: true

  validates :free_initial_meeting,
    inclusion: { in: [true, false] }

  validates :initial_meeting_duration,
    presence: true,
    if: ->{ free_initial_meeting? }

  validates :initial_advice_fee_structures,
    length: { minimum: 1 }

  validates :ongoing_advice_fee_structures,
    length: { minimum: 1 }

  validates :allowed_payment_methods,
    length: { minimum: 1 }

  validates :minimum_fixed_fee,
    allow_blank: true,
    numericality: { only_integer: true }

  validates *ADVICE_TYPES_ATTRIBUTES,
    inclusion: { in: [true, false] }

  validates :investment_sizes,
    length: { minimum: 1 }

  after_commit :geocode, if: :valid?
  after_commit :delete_elastic_search_entry, if: :destroyed?

  def telephone_number
    return nil unless self[:telephone_number]

    self[:telephone_number].gsub(' ', '')
  end

  def full_street_address
    [address_line_one, address_line_two, address_postcode, 'United Kingdom'].delete_if(&:blank?).join(', ')
  end

  def in_person_advice?
    in_person_advice_methods.present?
  end
  alias :postcode_searchable? :in_person_advice?

  def trading_name?
    parent.present?
  end

  alias_method :subsidiary?, :trading_name?

  def field_order
    [
      :email_address,
      :telephone_number,
      :address_line_one,
      :address_line_two,
      :address_town,
      :address_county,
      :address_postcode,
      :in_person_advice_methods,
      :free_initial_meeting,
      :initial_meeting_duration,
      :initial_advice_fee_structures,
      :ongoing_advice_fee_structures,
      :allowed_payment_methods,
      :minimum_fixed_fee,
      :percent_total,
      *ADVICE_TYPES_ATTRIBUTES,
      :investment_sizes
    ]
  end

  def geocode
    return if destroyed?
    GeocodeFirmJob.perform_later(self)
  end

  private

  def delete_elastic_search_entry
    DeleteFirmJob.perform_later(id)
  end

  def upcase_postcode
    address_postcode.upcase! if address_postcode.present?
  end
end
