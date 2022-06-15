require 'spec_helper'

RSpec.describe AutoUpdateRulesController, :type => :controller do

  render_views

  fixtures :users, :auto_update_rules, :projects

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
      params = {auto_update_rule: {note: "This is a note", final_status_id: 5, author_id: 1}} # Closed by Admin
      post :create, params: params

      expect(response).to redirect_to(auto_update_rules_path)
    end

  end

  context "Copy" do
    let!(:rule_to_copy) { AutoUpdateRule.find(4) }

    before do
      AutoUpdateRuleProject.create(project_id: 1, auto_update_rule_id: rule_to_copy.id)
      AutoUpdateRuleProject.create(project_id: 2, auto_update_rule_id: rule_to_copy.id)
    end

    let!(:rule_to_copy_projects_ids) { AutoUpdateRuleProject.where(auto_update_rule_id: rule_to_copy.id).map { |auto_update_rule_project| auto_update_rule_project.id } }

    it "GET assigns an existing rule to the view" do
      get :new, :params => {
        :id => rule_to_copy.id,
      }

      expect(response).to be_successful
      expect(assigns(:rule)).to be_a_new(AutoUpdateRule)
      new_rule_projects_ids = assigns(:rule).projects.map { |project| project.id }

      expect(new_rule_projects_ids).to eq(rule_to_copy_projects_ids)
    end

    it "Copy an auto-update rule" do
      expect do
        post :create, :params => {
          :auto_update_rule => { name: "Title of copy", author_id: User.current.id } ,
          :id => rule_to_copy.id,
        }
      end.to change { AutoUpdateRule.count }.by(1)
      auto_rule = AutoUpdateRule.last

      expect(response).to redirect_to(auto_update_rules_path)
      expect(auto_rule.author_id).not_to eq(rule_to_copy.author_id)
      expect(auto_rule.name).to eq('Title of copy')
      expect(auto_rule.name).to_not eq(rule_to_copy.name)
    end

    it "Copy an auto-update rule with project" do
        expect do
          post :create, :params => {
            :auto_update_rule => { name: "Title of copy",
                                   author_id: User.current.id,
                                   project_ids: rule_to_copy_projects_ids } ,
            :id => rule_to_copy.id,
          }
        end.to change { AutoUpdateRule.count }.by(1)
        .and change { AutoUpdateRuleProject.count }.by(2)

        expect(response).to redirect_to(auto_update_rules_path)

        new_rule = AutoUpdateRule.last
        new_rule_projects_ids = assigns(:rule).projects.map { |project| project.id }

        expect(new_rule.author_id).not_to eq(rule_to_copy.author_id)
        expect(new_rule_projects_ids).to eq(rule_to_copy_projects_ids)

    end
  end
end
