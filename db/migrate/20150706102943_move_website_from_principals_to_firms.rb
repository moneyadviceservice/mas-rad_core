class MoveWebsiteFromPrincipalsToFirms < ActiveRecord::Migration
  def up
    add_column :firms, :website_address, :string

    Principal.all.each do |principal|
      Firm.where(fca_number: principal.fca_number)
           .update_all(website_address: principal.website_address)
    end

    remove_column :principals, :website_address, :string
  end

  def down
    add_column :principals, :website_address, :string

    # This doesn't reverse the migration cleanly, but takes the website address
    # of the principal's parent firm. It will discard all websites on trading
    # name firms.
    Principal.all.each do |principal|
      principal.update(website_address: principal.firm.try(:website_address))
    end

    remove_column :firms, :website_address, :string
  end
end
