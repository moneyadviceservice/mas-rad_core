class ChangePercentageFieldsToBooleanFieldsOnFirm < ActiveRecord::Migration
  ADVICE_TYPES_ATTRIBUTES = [
    :retirement_income_products,
    :pension_transfer,
    :long_term_care,
    :equity_release,
    :inheritance_tax_and_estate_planning,
    :wills_and_probate,
    :other]

  def up
    ADVICE_TYPES_ATTRIBUTES.each do |field|
      # We add the boolean column
      add_column :firms, "#{field}_flag".to_sym, :boolean, null: false, default: false
      # Translate the old percentage values to the new boolean column
      Firm.where("#{field}_percent > ?", 0).update_all("#{field}_flag" => true)
      # And finally, remove the percentage column
      remove_column :firms, "#{field}_percent".to_sym, :integer
    end
  end

  def down
    ADVICE_TYPES_ATTRIBUTES.each do |field|
      # As above, but in reverse.
      # Since we've lost information, we can only migrate back by figuring
      #   true  => 100%
      #   false => 0%
      # Which won't validate since the fields won't add up to 100%, but it
      # will work in a pinch.
      add_column :firms, "#{field}_percent".to_sym, :integer
      Firm.where("#{field}_flag" => true).update_all("#{field}_percent" => 100)
      remove_column :firms, "#{field}_flag".to_sym, :boolean, null: false, default: false
    end
  end
end
