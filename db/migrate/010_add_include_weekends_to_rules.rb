class AddIncludeWeekendsToRules < ActiveRecord::Migration[5.2]
  def change
    add_column :auto_update_rules, :include_weekends, :boolean, default: true
  end
end
