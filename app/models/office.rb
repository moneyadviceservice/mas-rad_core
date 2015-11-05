class Office < ActiveRecord::Base
  include Geocodable

  ADDRESS_FIELDS = [
    :address_line_one,
    :address_line_two,
    :address_town,
    :address_county,
    :address_postcode
  ].freeze

  belongs_to :firm

  before_validation :upcase_postcode

  validates :email_address,
    presence: false,
    length: { maximum: 50 },
    format: { with: /.+@.+\..+/ }

  validates :telephone_number,
    presence: false,
    length: { maximum: 30 },
    format: { with: /\A[0-9 ]+\z/ }

  validates :address_line_one,
    presence: true,
    length: { maximum: 100 }

  validates :address_line_two,
    length: { maximum: 100 }

  validates :address_postcode,
    presence: true,
    format: { with: /\A[A-Z\d]{1,4} [A-Z\d]{1,3}\z/ }

  validates :address_town,
    presence: true,
    length: { maximum: 100 }

  validates :address_county,
    presence: false,
    length: { maximum: 100 }

  validates :disabled_access, inclusion: { in: [true, false] }

  def field_order
    [
      :address_line_one,
      :address_line_two,
      :address_town,
      :address_county,
      :address_postcode,
      :email_address,
      :telephone_number,
      :disabled_access
    ]
  end

  def telephone_number
    super.try { |x| x.gsub(' ', '') }
  end

  def full_street_address
    [address_line_one, address_line_two, address_postcode, 'United Kingdom'].reject(&:blank?).join(', ')
  end

  def geocode
    return false unless valid?
    return true unless needs_to_be_geocoded?

    self.coordinates = ModelGeocoder.geocode(self)

    geocoded?
  end

  def needs_to_be_geocoded?
    !geocoded? || has_address_changes?
  end

  def has_address_changes?
    ADDRESS_FIELDS.any? { |field| changed_attributes.include? field }
  end

  def save_with_geocoding
    geocode && save
  end

  def update_with_geocoding(office_params)
    self.attributes = office_params
    save_with_geocoding
  end

  private

  def upcase_postcode
    address_postcode.upcase! if address_postcode.present?
  end
end

