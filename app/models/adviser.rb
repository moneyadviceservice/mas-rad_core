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

  validates_acceptance_of :confirmed_disclaimer, accept: true

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

  after_save :geocode
  after_save :reindex_old_firm
  after_commit :run_commit_jobs

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
      :travel_distance,
      :confirmed_disclaimer
    ]
  end

  private

  # All record of what changed is gone by the time we get to the after_commit
  # hooks, so we need to store any important changes here to be actioned later.
  def flag_changes_for_after_commit
    @old_firm_id = firm_id_change.first if firm_id_changed?
  end

  def geocode
    if destroyed?
      run_after_commit(:geocode_parent_firm)
    elsif valid?
      run_after_commit(:geocode_self)
    end
  end

  def reindex_old_firm
    return unless firm_id_changed?
    return unless firm_id_change.first.present?
    run_after_commit(:reindex_previous_firm, firm_id_change.first)
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
        I18n.t('questionnaire.adviser.reference_number_un_matched')
      )
    end
  end

  def run_after_commit(method_symbol, *args)
    @jobs ||= []
    return if @jobs.any? { |job| job == [method_symbol, args] }
    @jobs << [method_symbol, args]
  end

  def run_commit_jobs
    @jobs.each { |method_symbol, args| send(method_symbol, *args) }
    @jobs = []
  end

  def commit_jobs
    firm.geocode
  end

  def geocode_self
    GeocodeAdviserJob.perform_later(self)
  end

  def reindex_previous_firm(firm_id)
    IndexFirmJob.perform_later(firm_id)
  end
end
