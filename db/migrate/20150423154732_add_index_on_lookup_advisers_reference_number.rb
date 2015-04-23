class AddIndexOnLookupAdvisersReferenceNumber < ActiveRecord::Migration
  def change
    add_index :lookup_advisers, :reference_number, unique: true
  end
end
