class Adviser < ActiveRecord::Base
  include Geocodable

  attr_reader :old_firm_id

  belongs_to :firm

  has_and_belongs_to_many :qualifications
  has_and_belongs_to_many :accreditations
  has_and_belongs_to_many :professional_standings
  has_and_belongs_to_many :professional_bodies

  before_validation :assign_name, if: :reference_number?

  before_validation :upcase_postcode

  validates :travel_distance,
    presence: true,
    inclusion: { in: TravelDistance.all.values }

  validates :postcode,
    presence: true,
    format: { with: /\A[A-Z\d]{1,4} ?[A-Z\d]{1,3}\z/ }

  validates :reference_number,
    presence: true,
    uniqueness: true,
    format: {
      with: /\A[A-Z]{3}[0-9]{5}\z/
    }

  validate :match_reference_number

  after_commit :geocode_and_reindex_firm
  after_commit :reindex_old_firm, if: :firm_id_changed?

  scope :sorted_by_name, -> { order(:name) }

  def self.on_firms_with_fca_number(fca_number)
    firms = Firm.where(fca_number: fca_number)
    where(firm: firms)
  end

  def self.move_all_to_firm(receiving_firm)
    transaction do
      current_scope.each do |adviser|
        adviser.update!(firm: receiving_firm)
      end
    end
  end

  def full_street_address
    "#{postcode}, United Kingdom"
  end

  def field_order
    [
      :reference_number,
      :postcode,
      :travel_distance
    ]
  end

  private

  def geocode_and_reindex_firm
    if destroyed?
      firm.geocode_and_reindex
    elsif valid?
      GeocodeAdviserJob.perform_later(self)
    end
  end

  def reindex_old_firm
    IndexFirmJob.perform_later(Firm.find(attribute_was(:firm_id)))
  end

  def upcase_postcode
    postcode.upcase! if postcode.present?
  end

  def assign_name
    self.name = Lookup::Adviser.find_by(
      reference_number: reference_number
    ).try(:name)
  end

  def match_reference_number
    unless Lookup::Adviser.exists?(reference_number: reference_number)
      errors.add(
        :reference_number,
        I18n.t('adviser.reference_number_unmatched')
      )
    end
  end
end
