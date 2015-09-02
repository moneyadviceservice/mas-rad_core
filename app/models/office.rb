class Office < ActiveRecord::Base
  belongs_to :firm

  before_validation :upcase_postcode

  validates :email_address,
    presence: true,
    length: { maximum: 50 },
    format: { with: /.+@.+\..+/ }

  validates :telephone_number,
    presence: true,
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
    presence: true,
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

  private

  def upcase_postcode
    address_postcode.upcase! if address_postcode.present?
  end
end

