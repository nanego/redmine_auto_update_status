require_dependency 'project'

class Project
  has_many :auto_update_rule_projects
  has_many :auto_update_rules, through: :auto_update_rule_projects
end
