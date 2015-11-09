class Adviser < ActiveRecord::Base
  include Geocodable
  include GeocodableSync

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

  scope :sorted_by_name, -> { order(:name) }

  after_save :flag_changes_for_after_commit
  after_commit :notify_indexer
  after_commit :reindex_old_firm

  def notify_indexer
    FirmIndexer.handle_aggregate_changed(self)
  end

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

  def has_address_changes?
    changed_attributes.include? :postcode
  end

  def add_geocoding_failed_error
    errors.add(:address, I18n.t("#{model_name.i18n_key}.geocoding.failure_message"))
  end

  def field_order
    [
      :reference_number,
      :postcode,
      :travel_distance
    ]
  end

  private

  # All record of what changed is gone by the time we get to the after_commit
  # hooks. So we cannot use #firm_id_changed? at that point. To work around
  # this we flag any important changes here to be actioned later.
  def flag_changes_for_after_commit
    @old_firm_id = firm_id_change.first if firm_id_changed?
  end

  def reindex_old_firm
    IndexFirmJob.perform_later(Firm.find(@old_firm_id)) if @old_firm_id.present?
    @old_firm_id = nil
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
