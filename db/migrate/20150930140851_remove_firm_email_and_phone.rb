class RemoveFirmEmailAndPhone < ActiveRecord::Migration
  class Firm < ActiveRecord::Base; has_many :offices, -> { order created_at: :asc }; end
  class Office < ActiveRecord::Base; belongs_to :firm; end

  def up
    remove_column :firms, :email_address
    remove_column :firms, :telephone_number

    # Data does not need to be migrated as the offices migration will have
    # already copied these two fields into an office record.
  end

  def down
    add_column :firms, :email_address, :string
    add_column :firms, :telephone_number, :string

    # Use the equivalent main office fields to repopulate
    Firm.all.select { |f| f.offices.any? }.each do |firm|
      main_office = firm.offices.first
      firm.update!(
        email_address: main_office.email_address,
        telephone_number: main_office.telephone_number
      )
    end
  end
end
