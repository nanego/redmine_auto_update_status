class AddMissingIndexes < ActiveRecord::Migration[7.2]
  def change
    add_index :auto_update_rules, :author_id, if_not_exists: true
    add_index :auto_update_rules, :project_id, if_not_exists: true
  end
end
