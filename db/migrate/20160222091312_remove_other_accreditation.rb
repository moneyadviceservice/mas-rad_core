class RemoveOtherAccreditation < ActiveRecord::Migration
  class Accreditation < ActiveRecord::Base
  end

  def up
    Accreditation.where(name: 'Other').destroy_all
  end

  def down
    # Unfortunately we can't just insert the 'Other' record, as there are parts
    # of `rad` and `rad_consumer` which rely on the 'Other' record having the
    # ID of '5'. This is due to translations and configuring whether or not to
    # show the record.
    #
    # You're allowed to roll back this migration, but be aware that if you're
    # using an older version of `rad` or `rad_consumer` they may throw errors
    # if this record doesn't exist.
  end
end
