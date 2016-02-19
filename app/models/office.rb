require 'uk_postcode'

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

  validates :telephone_number,
    presence: false,
    length: { maximum: 30 },
    format: { with: /\A[0-9 ]+\z/ }

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
      :disabled_access
    ]
  end

  def telephone_number=(new_phone_number)
    return super if new_phone_number.nil?
    super new_phone_number.gsub(/\s+/, ' ').strip
  end

  def full_street_address
    [address_line_one, address_line_two, address_postcode, 'United Kingdom'].reject(&:blank?).join(', ')
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

  def postcode_is_valid
    if address_postcode.nil? || !UKPostcode.parse(address_postcode).full_valid?
      errors.add(:address_postcode, 'is invalid')
    end
  end
end

