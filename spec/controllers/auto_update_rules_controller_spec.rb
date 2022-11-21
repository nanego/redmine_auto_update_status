require 'spec_helper'

RSpec.describe AutoUpdateRulesController, :type => :controller do

  render_views

  fixtures :users, :auto_update_rules, :projects, :issues, :trackers, :issue_statuses, :enumerations,
           :journals, :journal_details, :members, :member_roles, :roles
  fixtures :functions, :project_functions, :project_function_trackers if Redmine::Plugin.installed?(:redmine_limited_visibility)

  before do
    User.current = User.find(1)
    @request.session[:user_id] = 1 # admin
    Setting.default_language = 'en'
  end

  context "GET new" do

    it "assigns a blank rule to the view" do
      get :new
      expect(response).to be_successful
      expect(assigns(:rule)).to be_a_new(AutoUpdateRule)
    end

  end

  context "POST create" do

    it "redirects to auto update rules page" do
      params = { auto_update_rule: { note: "This is a note", final_status_id: 5, author_id: 1 } } # Closed by Admin
      post :create, params: params
      expect(response).to redirect_to(auto_update_rules_path)
    end

  end

  context "Copy" do
    let!(:rule_to_copy) { AutoUpdateRule.find(4) }

    before do
      rule_to_copy.projects = Project.where(id: [1, 2])
      rule_to_copy.save
    end

    it "initializes a copy of a rule" do
      get :copy, :params => {
        :id => rule_to_copy.id
      }
      expect(response).to be_successful
      expect(assigns(:rule)).to be_a_new(AutoUpdateRule)
      new_rule_projects_ids = assigns(:rule).projects.map(&:id)
      expect(new_rule_projects_ids).to eq(rule_to_copy.project_ids)
    end

    it "copies an auto-update rule" do
      expect do
        post :create, :params => {
          :auto_update_rule => { name: "Title of copy", author_id: User.current.id },
          :id => rule_to_copy.id,
        }
      end.to change { AutoUpdateRule.count }.by(1)
      auto_rule = AutoUpdateRule.last

      expect(response).to redirect_to(auto_update_rules_path)
      expect(auto_rule.author_id).not_to eq(rule_to_copy.author_id)
      expect(auto_rule.name).to eq('Title of copy')
      expect(auto_rule.name).to_not eq(rule_to_copy.name)
    end

    it "copies an auto-update rule with project" do
      expect do
        post :create, :params => {
          :auto_update_rule => { name: "Title of copy",
                                 author_id: User.current.id,
                                 project_ids: rule_to_copy.project_ids },
          :id => rule_to_copy.id,
        }
      end.to change { AutoUpdateRule.count }.by(1)
                                            .and change { AutoUpdateRuleProject.count }.by(2)

      expect(response).to redirect_to(auto_update_rules_path)

      new_rule = AutoUpdateRule.last
      new_rule_projects_ids = assigns(:rule).projects.map(&:id)

      expect(new_rule.author_id).not_to eq(rule_to_copy.author_id)
      expect(new_rule_projects_ids).to eq(rule_to_copy.project_ids)
    end
  end

  describe "Applying a rule manually" do

    let!(:rule) { AutoUpdateRule.find(1) }
    let!(:issue) { Issue.find(7) }

    it "applies a rule to a specific issue and change its status" do

      expect(rule.issues.count).to be > 0
      expect(rule.issues).to include(issue)
      expect(issue.status_id).to eq(1)

      expect do
        post :apply, :params => {
          :id => rule.id,
          :issue_id => issue.id
        }
      end.to change { issue.journals.count }.by(1)

      expect(response).to redirect_to(auto_update_rule_path(rule))
      expect(issue.reload.status_id).to eq(5)

      last_journal = issue.journals.last
      expect(last_journal.notes).to eq(rule.note)
      expect(last_journal.details).not_to be_empty
      journal_detail = last_journal.details.first
      expect(journal_detail.prop_key).to eq "status_id"
      expect(journal_detail.value).to eq "5"

    end

  end
end
