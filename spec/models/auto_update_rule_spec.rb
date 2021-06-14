require 'spec_helper'

RSpec.describe AutoUpdateRule, :type => :model do

  fixtures :auto_update_rules, :issues, :trackers, :issue_statuses, :projects, :enumerations

  let!(:rule) { AutoUpdateRule.find(1) }
  let!(:issue_7) { Issue.find(7) }

  context "attributes" do

    it "has initial_status_ids" do
      expect(rule).to have_attributes(initial_status_ids: [1, 2])
    end

    it "has final_status_id" do
      expect(rule).to have_attributes(final_status_id: 5)
    end

    it "has time_limit" do
      expect(rule).to have_attributes(time_limit: 5)
    end

    it "has note" do
      expect(rule).to have_attributes(note: 'Automatically closed')
    end

    it "has author_id" do
      expect(rule).to have_attributes(author_id: 1)
    end

    it "has tracker_ids" do
      expect(rule).to have_attributes(tracker_ids: nil)
    end

  end

  context "rule's issues" do
    it "returns some issues for a specific rule" do
      expect(rule.issues.size).to be > 1
      expect(rule.issues).to include issue_7
    end
  end

  context "apply rules" do
    it 'applies a rule to a specific issue' do
      expect(rule.issues).to include issue_7
      expect(issue_7.status_id).to eq 1

      rule.apply_to_issue(issue_7)
      issue_7.reload

      expect(rule.issues).to_not include issue_7
      expect(issue_7.status_id).to eq 5
    end

    it "can apply rules without changing the status" do
      rule.update(final_status_id: 1)

      expect(rule.issues).to include issue_7
      expect(issue_7.status_id).to eq 1
      expect(issue_7.last_notes).to eq nil

      rule.apply_to_issue(issue_7)
      issue_7.reload

      expect(rule.issues).to_not include issue_7
      expect(issue_7.status_id).to eq 1
      expect(issue_7.last_notes).to eq "Automatically closed"
    end

    it "can apply a rule without final status" do
      rule.update(final_status_id: nil)

      # Initial state
      expect(rule.issues).to include issue_7
      expect(issue_7.status_id).to eq 1
      expect(issue_7.last_notes).to eq nil

      # Apply rule
      rule.apply_to_issue(issue_7)

      # Result
      issue_7.reload
      expect(rule.issues).to include issue_7
      expect(issue_7.status_id).to eq 1
      expect(issue_7.last_notes).to eq "Automatically closed"

      # Re-applying the same rule does NOT add the same notes multiple times
      expect{
        rule.apply_to_issue(issue_7)
      }.to_not change(Journal, :count)
    end
  end

end
