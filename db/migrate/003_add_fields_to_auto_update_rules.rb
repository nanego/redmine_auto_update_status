class AddFieldsToAutoUpdateRules < ActiveRecord::Migration[5.2]
  def change
    add_column :auto_update_rules, :enabled, :boolean
    add_column :auto_update_rules, :organization_ids, :string
  end
end
