class AddDeleteIssuesOrAttachmentsToRules < ActiveRecord::Migration[6.1]
  def change
    add_column :auto_update_rules, :delete_issue, :boolean, default: false
    add_column :auto_update_rules, :delete_all_attachments, :boolean, default: false
  end
end
