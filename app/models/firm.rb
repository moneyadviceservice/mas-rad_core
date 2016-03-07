class Firm < ActiveRecord::Base
  FREE_INITIAL_MEETING_VALID_VALUES = [true, false].freeze

  # We use a scalar required field as a marker to detect a record saved with validation
  REGISTERED_MARKER_FIELD = :free_initial_meeting
  REGISTERED_MARKER_FIELD_VALID_VALUES = FREE_INITIAL_MEETING_VALID_VALUES

  ADVICE_TYPES_ATTRIBUTES = [
    :retirement_income_products_flag,
    :pension_transfer_flag,
    :long_term_care_flag,
    :equity_release_flag,
    :inheritance_tax_and_estate_planning_flag,
    :wills_and_probate_flag
  ]

  scope :registered, -> { where.not(REGISTERED_MARKER_FIELD => nil) }
  scope :sorted_by_registered_name, -> { order(:registered_name) }

  def self.languages_used
    pluck('DISTINCT unnest("languages")').sort
  end

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
  has_many :offices, -> { order created_at: :asc }, dependent: :destroy
  has_many :subsidiaries, class_name: 'Firm', foreign_key: :parent_id, dependent: :destroy
  has_many :trading_names, class_name: 'Firm', foreign_key: :parent_id, dependent: :destroy
  has_many :qualifications, -> { reorder('').uniq }, through: :advisers
  has_many :accreditations, -> { reorder('').uniq }, through: :advisers

  attr_accessor :percent_total
  attr_accessor :primary_advice_method

  before_validation :clear_inapplicable_advice_methods,
                    if: -> { primary_advice_method == :remote }
  before_validation :clear_blank_languages
  before_validation :deduplicate_languages

  validates :website_address,
    allow_blank: true,
    length: { maximum: 100 },
    format: { with: /\A(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+/ }

  validates :free_initial_meeting,
    inclusion: { in: FREE_INITIAL_MEETING_VALID_VALUES }

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
    allow_blank: false,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than: 2147483648 # max value for postgres integer type
    }

  validates :in_person_advice_methods,
    presence: true,
    if: ->{ primary_advice_method == :local }

  validates :other_advice_methods,
    presence: true,
    if: ->{ primary_advice_method == :remote }

  validates *ADVICE_TYPES_ATTRIBUTES,
    inclusion: { in: [true, false] }

  validates :primary_advice_method,
    presence: true

  validate :languages do
    unless languages.all? { |lang| Languages::AVAILABLE_LANGUAGES_ISO_639_3_CODES.include?(lang) }
      errors.add(:languages, :invalid)
    end
  end

  validate do
    unless advice_types.values.any?
      errors.add(:advice_types, :invalid)
    end
  end

  validates :investment_sizes,
    length: { minimum: 1 }

  after_commit :notify_indexer

  def notify_indexer
    FirmIndexer.handle_firm_changed(self)
  end

  # A heuristic that allows us to infer validity
  #
  # This method is basically a cheap way to answer the question: has this
  # record ever been saved with validation enabled?
  def registered?
    # false is a valid value so we cannot use `.present?`
    !(send(REGISTERED_MARKER_FIELD).nil?)
  end

  if Rails.env.test?
    # A helper to shield tests from modifying the marker field directly
    def __set_registered(state)
      new_value = (state) ? REGISTERED_MARKER_FIELD_VALID_VALUES.first : nil
      send("#{REGISTERED_MARKER_FIELD}=", new_value)
    end
    alias_method :__registered=, :__set_registered
  end

  enum status: { independent: 1, restricted: 2 }

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
      :website_address,
      :address_line_one,
      :address_line_two,
      :address_town,
      :address_county,
      :address_postcode,
      :primary_advice_method,
      :in_person_advice_methods,
      :other_advice_methods,
      :free_initial_meeting,
      :initial_meeting_duration,
      :initial_advice_fee_structures,
      :ongoing_advice_fee_structures,
      :allowed_payment_methods,
      :minimum_fixed_fee,
      :percent_total,
      *ADVICE_TYPES_ATTRIBUTES,
      :ethical_investing_flag,
      :sharia_investing_flag,
      :languages,
      :investment_sizes
    ]
  end

  def advice_types
    ADVICE_TYPES_ATTRIBUTES.map { |a| [a, self[a]] }.to_h
  end

  def primary_advice_method
    return @primary_advice_method.to_sym if @primary_advice_method
    infer_primary_advice_method
  end

  def main_office
    offices.first
  end

  def publishable?
    registered? && offices.any? && !missing_advisers?
  end

  def missing_advisers?
    (primary_advice_method == :local) && advisers.empty?
  end

  private

  def infer_primary_advice_method
    if in_person_advice_methods.any?
      :local
    elsif other_advice_methods.any?
      :remote
    else
      nil
    end
  end

  def clear_inapplicable_advice_methods
    self.in_person_advice_methods = []
  end

  def clear_blank_languages
    languages.reject! &:blank?
  end

  def deduplicate_languages
    languages.uniq!
  end
end
