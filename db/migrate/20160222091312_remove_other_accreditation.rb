class RemoveOtherAccreditation < ActiveRecord::Migration
  class Accreditation < ActiveRecord::Base
  end

  def up
    Accreditation.where(name: 'Other').destroy_all
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
