require 'uk_postcode'
require 'uk_phone_numbers'

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

  validates :email_address,
    presence: false,
    length: { maximum: 50 },
    format: { with: /.+@.+\..+/ }

  validate :telephone_number_is_valid

  validates :address_line_one,
    presence: true,
    length: { maximum: 100 }

  validates :address_line_two,
    length: { maximum: 100 }

  validate :postcode_is_valid

  validates :address_town,
    presence: true,
    length: { maximum: 100 }

  validates :address_county,
    presence: false,
    length: { maximum: 100 }

  validates :disabled_access, inclusion: { in: [true, false] }

  after_commit :notify_indexer

  def notify_indexer
    FirmIndexer.handle_aggregate_changed(self)
  end

  def field_order
    [
      :address_line_one,
      :address_line_two,
      :address_town,
      :address_county,
      :address_postcode,
      :email_address,
      :telephone_number,
      :disabled_access,
      :website
    ]
  end

  def telephone_number=(new_phone_number)
    super cleanup_telephone_number(new_phone_number)
  end

  def telephone_number
    return format_telephone_number(cleanup_telephone_number(super))
  end

  # The Geocodable interface expect an object that responds to
  # Geocodable#full_street_address. So, to respect the interface,
  # we created internally the method postcode_only_address,
  # to reflect what this object returns differently from the others.
  #
  def full_street_address
    postcode_only_address
  end

  def has_address_changes?
    ADDRESS_FIELDS.any? { |field| changed_attributes.include? field }
  end

  def add_geocoding_failed_error
    errors.add(:geocoding, I18n.t("#{model_name.i18n_key}.geocoding.failure_message"))
  end

  def address_postcode=(postcode)
    return super unless postcode.present?

    parsed_postcode = UKPostcode.parse(postcode)

    return super unless parsed_postcode.full_valid?

    new_postcode = "#{parsed_postcode.outcode} #{parsed_postcode.incode}"
    write_attribute(:address_postcode, new_postcode)
  end

  private

  def postcode_only_address
    [address_postcode, 'United Kingdom'].join(', ')
  end

  def postcode_is_valid
    if address_postcode.nil? || !UKPostcode.parse(address_postcode).full_valid?
      errors.add(:address_postcode, 'is invalid')
    end
  end

  def telephone_number_is_valid
    if telephone_number.nil? || !UKPhoneNumbers.valid?(telephone_number.gsub(' ', ''))
      errors.add(:telephone_number, I18n.t("#{model_name.i18n_key}.telephone_number.invalid_format"))
    end
  end

  def cleanup_telephone_number(telephone_number)
    telephone_number.try { |t| t.gsub(/\s+/, ' ').strip }
  end

  def format_telephone_number(telephone_number)
    telephone_number.try { |t| UKPhoneNumbers.format(t) || t }
  end
end
