class AddOrderingOnReferenceData < ActiveRecord::Migration
  REFERENCE_TABLES = [
    :accreditations,
    :allowed_payment_methods,
    :in_person_advice_methods,
    :initial_advice_fee_structures,
    :initial_meeting_durations,
    :investment_sizes,
    :ongoing_advice_fee_structures,
    :other_advice_methods,
    :professional_bodies,
    :professional_standings,
    :qualifications
  ]

  def up
    REFERENCE_TABLES.each do |table|
      add_column table, :order, :integer, null: false, default: 0

      table.to_s.classify.constantize.unscoped.order(:id).each do |m|
        m.update_attribute(:order, m.id)
      end
    end
  end

  def down
    REFERENCE_TABLES.each do |table|
      remove_column table, :order
    end
  end
end
