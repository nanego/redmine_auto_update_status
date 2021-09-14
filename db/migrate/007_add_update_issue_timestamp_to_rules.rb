class AddUpdateIssueTimestampToRules < ActiveRecord::Migration[5.2]
  def change
    add_column :auto_update_rules, :update_issue_timestamp, :boolean
  end
end
