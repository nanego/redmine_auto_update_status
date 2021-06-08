module RedmineAutoUpdateStatus
  module IssuePatch
    def change_status(note:, user:, new_status_id:)
      init_journal(user, note)
      new_status = IssueStatus.find(new_status_id)
      self.attributes = {"status_id" => "#{new_status.id}"} if new_status
      save
    end

    def add_notes(notes:, user:)
      if last_notes != notes
        Journal.create(:journalized => self, :user => user, :notes => notes)
      end
    end
  end
end
