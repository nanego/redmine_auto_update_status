require 'spec_helper'

RSpec.describe AutoUpdateRule, :type => :model do

  fixtures :auto_update_rules, :issues, :trackers, :issue_statuses, :projects, :enumerations,
           :users, :journals, :journal_details, :members, :member_roles, :roles
  fixtures :functions, :project_functions, :project_function_trackers if Redmine::Plugin.installed?(:redmine_limited_visibility)

  let!(:rule) { AutoUpdateRule.find(1) }
  let!(:rule_without_final_status) { AutoUpdateRule.find(2) }
  let!(:rule_with_new_priority) { AutoUpdateRule.find(3) }
  let!(:rule_to_copy) { AutoUpdateRule.find(4) }
  let!(:issue_7) { Issue.find(7) }

  before do
    User.current = User.find(1)
  end

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

    it "has final_priority" do
      expect(rule_with_new_priority).to have_attributes(final_priority: 'higher')
    end

  end

  context "rule's issues" do
    it "returns some issues for a specific rule" do
      expect(rule.issues.size).to be > 1
      expect(rule.issues).to include issue_7
    end

    it "returns some issues for a rule with assignment filter" do
      rule.assignment = :none
      expect(rule.issues.size).to be > 1
      expect(rule.issues).to include issue_7
      expect(rule.issues).to eq rule.issues.reject { |i| i.assigned_to.present? }
    end

    it "returns the issues assigned to a user" do
      rule.assignment = :a_member
      expect(rule.issues.size).to be > 1
      expect(rule.issues).to include Issue.find(2)
      expect(rule.issues).to eq rule.issues.reject { |i| i.assigned_to.blank? }
    end

    if Redmine::Plugin.installed?(:redmine_limited_visibility)
      it "returns the issues assigned to a functional-role" do
        function = Function.all.first
        issue_2 = Issue.find(2)
        issue_2.update_attribute(:assigned_to_id, nil)
        issue_2.update_attribute(:assigned_to_function_id, function.id)
        expect(issue_2.reload.assigned_function).to eq function
        expect(issue_2.reload.assigned_to).to be_nil

        expect(rule.update(assignment: "a_functional_role", time_limit: nil)).to be_truthy

        expect(rule.issues.size).to be >= 1
        expect(rule.issues).to include issue_2
      end
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

    it 'applies a rule to a specific issue and change priority' do
      expect(rule_with_new_priority.issues).to include issue_7
      expect(issue_7.status_id).to eq 1
      expect(issue_7.priority_id).to eq 5

      rule_with_new_priority.apply_to_issue(issue_7)
      issue_7.reload

      expect(issue_7.status_id).to eq 1
      expect(issue_7.priority_id).to eq 6
    end

    it 'applies a rule to a specific issue and change both priority and status' do
      rule_with_new_priority.update(final_status_id: 5, final_priority: 'higher')

      expect(rule_with_new_priority.issues).to include issue_7
      expect(issue_7.status_id).to eq 1
      expect(issue_7.priority_id).to eq 5

      rule_with_new_priority.apply_to_issue(issue_7)
      issue_7.reload

      expect(issue_7.status_id).to eq 5
      expect(issue_7.priority_id).to eq 6
    end

    it "can apply rules without changing the status" do
      rule.update(final_status_id: 1)

      expect(rule.issues).to include issue_7
      expect(issue_7.status_id).to eq 1
      expect(issue_7.last_saved_note).to eq nil

      rule.apply_to_issue(issue_7)
      issue_7.reload

      expect(rule.issues).to_not include issue_7
      expect(issue_7.status_id).to eq 1
      expect(issue_7.last_saved_note).to eq "Automatically closed"
    end

    it "can apply a rule without final status" do
      initial_timestamp = issue_7.updated_on

      # Initial state
      expect(rule_without_final_status.final_status_id).to be_nil
      expect(rule_without_final_status.issues).to include issue_7
      expect(issue_7.status_id).to eq 1
      expect(issue_7.last_saved_note).to eq nil

      # Apply rule
      rule_without_final_status.apply_to_issue(issue_7)

      # Result
      issue_7.reload

      expect(rule_without_final_status.issues).to include issue_7
      expect(issue_7.status_id).to eq 1
      expect(issue_7.last_saved_note).to eq "Note added automatically"
      expect(issue_7.updated_on).to eq initial_timestamp

      # Re-applying the same rule does NOT add the same notes multiple times
      expect {
        rule_without_final_status.apply_to_issue(issue_7)
      }.to_not change(Journal, :count)
    end
  end

  it "can apply a rule without final status AND update issue timestamp" do
    initial_timestamp = issue_7.updated_on
    rule_without_final_status.update(update_issue_timestamp: true)

    # Initial state
    expect(rule_without_final_status.final_status_id).to be_nil
    expect(rule_without_final_status.issues).to include issue_7
    expect(issue_7.status_id).to eq 1
    expect(issue_7.last_saved_note).to eq nil

    # Apply rule
    rule_without_final_status.apply_to_issue(issue_7)

    # Result
    issue_7.reload

    expect(rule_without_final_status.issues).to_not include issue_7 #Issue has now been removed from rule.issues
    expect(issue_7.status_id).to eq 1
    expect(issue_7.journals).to_not be_empty
    expect(issue_7.last_saved_note).to eq "Note added automatically"
    expect(issue_7.updated_on).to_not eq initial_timestamp

    # Re-applying the same rule does NOT add the same notes multiple times
    expect {
      rule_without_final_status.apply_to_issue(issue_7)
    }.to_not change(Journal, :count)
  end

  context "copy" do
    it "copy a rule" do
      new_rule = rule_to_copy.copy
      expect(new_rule).to have_attributes(:initial_status_ids => rule_to_copy.initial_status_ids,
                                          :final_status_id => rule_to_copy.final_status_id,
                                          :time_limit => rule_to_copy.time_limit,
                                          :include_weekends => rule_to_copy.include_weekends,
                                          :note => rule_to_copy.note,
                                          :project_id => rule_to_copy.project_id,
                                          :enabled => rule_to_copy.enabled,
                                          :organization_ids => rule_to_copy.organization_ids,
                                          :tracker_ids => rule_to_copy.tracker_ids,
                                          :update_issue_timestamp => rule_to_copy.update_issue_timestamp,
                                          :assignment => rule_to_copy.assignment,
                                          :final_priority => rule_to_copy.final_priority)
      expect(new_rule.id).to_not eq rule_to_copy.id
      expect(new_rule.author_id).to_not eq rule_to_copy.author_id
      expect(new_rule.name).to_not eq rule_to_copy.name
    end
  end

  context "limit_date_without_working_days" do
    it "returns a Friday if today is a Monday and the delay is 1 day" do
      expect(rule.limit_date_without_working_days(delay: 1, date: Date.parse("2022-06-20"))).to eq Date.parse("2022-06-17")
    end

    it "returns a Thursday if today is a Sunday and the delay is 2 days" do
      expect(rule.limit_date_without_working_days(delay: 2, date: Date.parse("2022-06-19"))).to eq Date.parse("2022-06-16")
    end

    it "returns a Wednesday if today is a Saturday and the delay is 3 days" do
      expect(rule.limit_date_without_working_days(delay: 3, date: Date.parse("2022-06-18"))).to eq Date.parse("2022-06-15")
    end

    it "returns a Tuesday if today is a Monday and the delay is 10 days" do
      expect(rule.limit_date_without_working_days(delay: 10, date: Date.parse("2022-06-20"))).to eq Date.parse("2022-06-06")
    end
  end

  context "Update auto_update_rule_projects table in case of cascade deleting" do
    let(:project) { Project.last }
    before do
      AutoUpdateRuleProject.create(project: project, auto_update_rule: rule)
    end

    it "When delete a rule" do
      expect do
        rule.destroy
      end.to change { AutoUpdateRuleProject.count }.by(-1)
    end

    it "When delete a project" do
      expect do
        project.destroy
      end.to change { AutoUpdateRuleProject.count }.by(-1)
    end
  end
end
