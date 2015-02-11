module Lookup
  class Adviser < ActiveRecord::Base
    validates_length_of   :reference_number, is: 8
    validates_presence_of :name

    def self.table_name
      "lookup_#{super}"
    end
  end
end
