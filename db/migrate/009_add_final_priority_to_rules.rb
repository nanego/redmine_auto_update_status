class AddFinalPriorityToRules < ActiveRecord::Migration[5.2]
  def change
    add_column :auto_update_rules, :final_priority, :string
  end
end
