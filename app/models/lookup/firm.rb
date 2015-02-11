module Lookup
  class Firm < ActiveRecord::Base
    has_many :subsidiaries, primary_key: :fca_number, foreign_key: :fca_number

    validates :fca_number,
      length: { is: 6 },
      numericality: { only_integer: true }

    def subsidiaries?
      subsidiaries.present?
    end

    def self.table_name
      "lookup_#{super}"
    end
  end
end
