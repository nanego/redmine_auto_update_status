module RedmineAutoUpdateStatus
  module IssuePatch

    def add_notes(notes:, user:)
      if last_saved_note != notes
        Journal.create(:journalized => self, :user => user, :notes => notes)
      end
    end

    def last_saved_note
      journals.where.not(notes: '').reorder(:id => :desc).first.try(:notes)
    end

    def add_notes_and_update_issue(notes:, user:, changes: {})
      if last_saved_note != notes
        journal = init_journal(user, notes)
        journal.details = []
        changes.each do |attribute, values|
          journal.details << JournalDetail.new(:property => 'attr',
                                               :prop_key => attribute,
                                               :old_value => values.first,
                                               :value => values.last)
        end
      end
      save
    end

    def auto_update_by_rule(rule)
      new_status = IssueStatus.find(rule.final_status_id) if rule.final_status_id.present?
      new_priority = rule.next_priority_for(issue: self) if rule.final_priority.present?
      if new_status || new_priority
        changes = {}
        changes["status_id"] = [status_id, new_status.id] if new_status
        changes["priority_id"] = [priority_id, new_priority.id] if new_priority
        changes.each { |attr, values| self.attributes = { attr => "#{values[1]}" } }
        add_notes_and_update_issue(notes: rule.note, user: rule.author, changes: changes)
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

Issue.prepend RedmineAutoUpdateStatus::IssuePatch
