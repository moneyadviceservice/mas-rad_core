module Lookup
  class Firm < ActiveRecord::Base
    has_many :trading_names, primary_key: :fca_number, foreign_key: :fca_number

    validates :fca_number,
      length: { is: 6 },
      numericality: { only_integer: true }

    def trading_names?
      trading_names.present?
    end

    def self.table_name
      "lookup_#{super}"
    end
  end
end
