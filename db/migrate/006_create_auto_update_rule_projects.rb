class CreateAutoUpdateRuleProjects < ActiveRecord::Migration[5.2]
  def self.up
    create_table :auto_update_rule_projects do |t|
      t.references :auto_update_rule
      t.references :project
    end unless ActiveRecord::Base.connection.table_exists? 'auto_update_rule_projects'
    add_index :auto_update_rule_projects, :project_id unless index_exists?(:auto_update_rule_projects, :project_id)
    add_index :auto_update_rule_projects, [:auto_update_rule_id, :project_id], :unique => true, name: "index_auto_update_rule_id_and_project_id" unless index_exists?(:auto_update_rule_id, [:issue_status_id, :project_id], :unique => true, name: "index_auto_update_rule_id_and_project_id")

    AutoUpdateRule.all.each do |rule|
      previous_project = rule.try(:project)
      if previous_project.present?
        rule.projects = previous_project.self_and_descendants
        rule.save
      end
    end
  end

  def self.down
    drop_table :auto_update_rule_projects
  end
end
