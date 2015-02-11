class Principal < ActiveRecord::Base
  self.primary_key = 'token'

  before_create :generate_token
  after_create  :associate_firm

  has_one :firm, primary_key: :fca_number, foreign_key: :fca_number

  validates :fca_number,
    presence: true,
    uniqueness: true,
    length: { is: 6 },
    numericality: { only_integer: true }

  validates :email_address,
    presence: true,
    uniqueness: true,
    length: { maximum: 50 },
    format: { with: /.+@.+\..+/ }

  validates :first_name, :last_name, :job_title, presence: true, length: 2..80

  validates :telephone_number,
    presence: true,
    length: { maximum: 50 },
    format: { with: /\A[0-9 ]+\z/ }

  validates :website_address,
    allow_blank: true,
    length: { maximum: 100 }

  validates_acceptance_of :confirmed_disclaimer, accept: true

  validate :match_fca_number, if: :fca_number?

  def to_param
    token.parameterize
  end

  def lookup_firm
    @lookup_firm ||= Lookup::Firm.find_by(fca_number: fca_number)
  end

  delegate :subsidiaries?, to: :lookup_firm

  def field_order
    [
      :fca_number,
      :website_address,
      :first_name,
      :last_name,
      :job_title,
      :email_address,
      :telephone_number,
      :confirmed_disclaimer
    ]
  end

  def find_or_create_subsidiary(id)
    subsidiary = lookup_firm.subsidiaries.find(id)

    find_subsidiary(subsidiary).tap do |firm|
      firm.save(validate: false) unless firm.persisted?
    end
  end

  private

  def find_subsidiary(subsidiary)
    firm.subsidiaries.find_or_initialize_by(
      registered_name: subsidiary.name,
      fca_number: subsidiary.fca_number
    )
  end

  def associate_firm
    Firm.new(fca_number: lookup_firm.fca_number, registered_name: lookup_firm.registered_name).tap do |f|
      f.save!(validate: false)
    end
  end

  def match_fca_number
    unless Lookup::Firm.exists?(fca_number: self.fca_number)
      errors.add(
        :fca_number,
        I18n.t('registration.principal.fca_number_un_matched')
      )
    end
  end

  def generate_token
    self.token = SecureRandom.hex(4)
  end
end
