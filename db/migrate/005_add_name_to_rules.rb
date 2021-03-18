class AddNameToRules < ActiveRecord::Migration[5.2]
  def change
    add_column :auto_update_rules, :name, :string
  end
end
