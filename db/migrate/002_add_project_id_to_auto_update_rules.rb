class AddProjectIdToAutoUpdateRules < ActiveRecord::Migration[5.2]
  def change
    add_column :auto_update_rules, :project_id, :integer
  end
end
