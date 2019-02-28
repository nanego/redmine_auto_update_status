class AutoUpdateRule < ActiveRecord::Base

  include Redmine::SafeAttributes

  serialize :initial_status_ids

  safe_attributes "initial_status_ids", "final_status_id", "time_limit", "note", "author_id", "project_id"

  validates_presence_of :final_status_id, :time_limit

  belongs_to :project

  def issues
    initial_statuses = IssueStatus.where(id: initial_status_ids)
    issues_to_change = Issue.order(updated_on: :desc)
    issues_to_change = issues_to_change.where(status_id: initial_statuses) if initial_statuses
    issues_to_change = issues_to_change.where("updated_on < ?", time_limit.days.ago) if time_limit
    issues_to_change
  end

end
