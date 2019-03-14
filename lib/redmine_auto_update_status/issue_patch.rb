module RedmineAutoUpdateStatus
  module IssuePatch
    def change_status(note:, user:, new_status_id:)
      init_journal(user, note)
      new_status = IssueStatus.find(new_status_id)
      self.attributes = {"status_id" => "#{new_status.id}"} if new_status
      save
    end
  end
end
