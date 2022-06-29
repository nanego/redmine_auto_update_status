require_dependency 'project'

class Project
  has_many :auto_update_rule_projects, :dependent => :destroy
  has_many :auto_update_rules, through: :auto_update_rule_projects
end
