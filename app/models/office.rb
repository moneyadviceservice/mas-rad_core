class Office < ActiveRecord::Base
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

  after_commit :geocode_and_reindex_firm

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

  private

  def upcase_postcode
    address_postcode.upcase! if address_postcode.present?
  end

  def geocode_and_reindex_firm
    return if destroyed?
    if valid? and main_office?
      firm.geocode_and_reindex # until we move the geocoding to offices, geocode the firm if this is the main office
    end
  end

  def main_office?
    firm.try(:main_office) == self
  end
end

