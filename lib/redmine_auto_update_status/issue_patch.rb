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

    def auto_update_by_rule(rule)
      new_status = IssueStatus.find(rule.final_status_id) if rule.final_status_id.present?
      new_priority = rule.next_priority_for(issue: self) if rule.final_priority.present?
      if new_status || new_priority
        self.attributes = { "status_id" => "#{new_status.id}" } if new_status
        self.attributes = { "priority_id" => "#{new_priority.id}" } if new_priority
        add_notes_and_update_issue(notes: rule.note, user: rule.author)
      else
        if rule.update_issue_timestamp
          add_notes_and_update_issue(notes: rule.note, user: rule.author)
        else
          add_notes(notes: rule.note, user: rule.author)
        end
      end
    end

  end
end
