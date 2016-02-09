class AddBypassReferenceNumberCheckToAdvisers < ActiveRecord::Migration
  def change
    add_column :advisers, :bypass_reference_number_check, :boolean, default: false
  end
end
