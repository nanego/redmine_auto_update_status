require_dependency 'project'

module RedmineAutoUpdateStatus::ProjectPatch
  def self.included(base)
    base.class_eval do
      has_many :auto_update_rule_projects, :dependent => :destroy
      has_many :auto_update_rules, through: :auto_update_rule_projects
    end
  end
end

class Project
  include RedmineAutoUpdateStatus::ProjectPatch
end
