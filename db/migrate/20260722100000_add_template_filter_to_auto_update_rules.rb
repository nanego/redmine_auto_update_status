class AddTemplateFilterToAutoUpdateRules < ActiveRecord::Migration[7.2]
  def change
    add_column :auto_update_rules, :template_filter_mode, :string, default: 'all'
    add_column :auto_update_rules, :issue_template_id, :integer, null: true
  end
end
