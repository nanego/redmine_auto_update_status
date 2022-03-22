class AddAssignmentToRules < ActiveRecord::Migration[5.2]
  def change
    add_column :auto_update_rules, :assignment, :string
  end
end
