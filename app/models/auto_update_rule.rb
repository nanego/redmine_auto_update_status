class AutoUpdateRule < ActiveRecord::Base

  include Redmine::SafeAttributes

  serialize :initial_status_ids
  serialize :tracker_ids
  serialize :organization_ids

  safe_attributes "name", "initial_status_ids", "final_status_id", "time_limit", "note", "author_id", "project_id", "enabled", "organization_ids", "tracker_ids"

  validates_presence_of :final_status_id, :author_id

  belongs_to :project
  belongs_to :author, class_name: 'User', foreign_key: :author_id

  scope :active, -> { where(enabled: true) }

  def issues
    initial_statuses = IssueStatus.where(id: initial_status_ids)
    issues_to_change = Issue.joins(:project).where('projects.status = ?', Project::STATUS_ACTIVE).order(updated_on: :desc)

    issues_to_change = issues_to_change.where(status_id: initial_statuses) if initial_statuses
    issues_to_change = issues_to_change.where("issues.updated_on < ?", time_limit.days.ago) if time_limit
    issues_to_change = issues_to_change.where(project: project.self_and_descendants) if project
    issues_to_change = issues_to_change.where(tracker_id: tracker_ids.reject(&:blank?)) if tracker_ids.present? && tracker_ids.reject(&:blank?).present?

    if Redmine::Plugin.installed?(:redmine_organizations) && organization_ids.present?
      assigned_to_ids = User.where(organization_id: organization_ids).pluck(:id)
      issues_to_change = issues_to_change.where(assigned_to_id: assigned_to_ids) if assigned_to_ids.present?
    end

    issues_to_change
  end

  def apply_to_all_issues
    issues.find_each do |issue|
      issue.change_status(new_issue_params)
    end
  end

  def apply_to_issue(issue)
    if issues.include?(issue)
      issue.change_status(new_issue_params)
    end
  end

  def new_issue_params
    { note: note, user: author, new_status_id: final_status_id }
  end

end
