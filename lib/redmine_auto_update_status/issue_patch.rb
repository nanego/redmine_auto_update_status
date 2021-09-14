module RedmineAutoUpdateStatus
  module IssuePatch

    def add_notes(notes:, user:)
      if last_notes != notes
        Journal.create(:journalized => self, :user => user, :notes => notes)
      end
    end

    def add_notes_and_update_issue(notes:, user:)
      if last_notes != notes
        init_journal(user, notes)
      end
      save
    end

    def auto_update(notes:, user:, new_status_id:, update_issue_timestamp:)
      if new_status_id.present?
        new_status = IssueStatus.find(new_status_id)
        if new_status
          self.attributes = { "status_id" => "#{new_status.id}" }
          add_notes_and_update_issue(notes: notes, user: user)
        end
      else
        if update_issue_timestamp
          add_notes_and_update_issue(notes: notes, user: user)
        else
          add_notes(notes: notes, user: user)
        end
      end
    end

  end
end
