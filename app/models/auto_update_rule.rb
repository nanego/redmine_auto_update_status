class AutoUpdateRule < ActiveRecord::Base

  include Redmine::SafeAttributes

  serialize :initial_status_ids
  serialize :tracker_ids
  serialize :organization_ids

  safe_attributes "name", "initial_status_ids", "final_status_id", "time_limit", "note", "author_id", "project_ids",
                  "project_id", "enabled", "organization_ids", "tracker_ids", "update_issue_timestamp", "assignment", "final_priority"

  validates_presence_of :author_id

  belongs_to :project # TODO Remove this association later, after migration
  has_many :auto_update_rule_projects
  has_many :projects, through: :auto_update_rule_projects
  belongs_to :author, class_name: 'User', foreign_key: :author_id

  scope :active, -> { where(enabled: true) }

  ASSIGNMENT_FILTER_VALUES = [:none, :a_member] + (Redmine::Plugin.installed?(:redmine_limited_visibility) ? [:a_functional_role] : [])

  def issues
    initial_statuses = IssueStatus.where(id: initial_status_ids)
    issues_to_change = Issue.joins(:project).where('projects.status = ?', Project::STATUS_ACTIVE).order(updated_on: :desc)

    issues_to_change = issues_to_change.where(status_id: initial_statuses) if initial_statuses
    issues_to_change = issues_to_change.where("issues.updated_on < ?", time_limit.days.ago) if time_limit
    issues_to_change = issues_to_change.where(project: projects) if projects.present?
    issues_to_change = issues_to_change.where(tracker_id: tracker_ids.reject(&:blank?)) if tracker_ids.present? && tracker_ids.reject(&:blank?).present?

    if Redmine::Plugin.installed?(:redmine_organizations) && organization_ids.present?
      assigned_to_ids = User.where(organization_id: organization_ids).pluck(:id)
      issues_to_change = issues_to_change.where(assigned_to_id: assigned_to_ids) if assigned_to_ids.present?
    end

    issues_to_change = issues_with_assignment(assignment, issues_to_change) if assignment.present?

    issues_to_change
  end

  def apply_to_all_issues
    issues.each do |issue|
      issue.auto_update_by_rule(self)
    end
  end

  def apply_to_issue(issue)
    return unless issues.include?(issue)
    issue.auto_update_by_rule(self)
  end

  def allowed_target_projects
    Project.active
  end

  def next_priority_for(issue:)
    return if final_priority.blank?
    if final_priority.to_i.to_s == final_priority.to_s
      IssuePriority.where(id: final_priority).first
    else
      if final_priority == 'higher'
        IssuePriority.where("position > ?", issue.priority.position).order(:position).first
      elsif final_priority == 'lower'
        IssuePriority.where("position < ?", issue.priority.position).order(:position).last
      end
    end
  end

  def copy
    new_rule = AutoUpdateRule.new
    new_rule.attributes = self.attributes.dup.except("id", "author_id")
    new_rule.name = "#{new_rule.name} (#{l('label_copy_extension_auto_update_rule')})"
    self.projects.each { |project| new_rule.projects << project }
    new_rule.author = User.current
    new_rule
  end

  private

  def issues_with_assignment(assignment, issues)
    case assignment
    when "none"
      issues.where(assigned_to_id: nil)
    when "a_member"
      issues.where.not(assigned_to_id: nil)
    when "a_functional_role"
      issues.where(assigned_to_id: nil).where.not(assigned_to_function_id: nil)
    else
      issues
    end
  end
end
