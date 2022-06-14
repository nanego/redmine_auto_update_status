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

    let!(:aurp1) { AutoUpdateRuleProject.first }
    let!(:aurp2) { AutoUpdateRuleProject.second }

    it "GET assigns an existing rule to the view" do
      get :copy, :params => {
        :id => rule_to_copy.id,
      }

      expect(response).to be_successful
      expect(assigns(:rule)).to be_a_new(AutoUpdateRule)
      expect(assigns(:rule).projects.first.id).to eq(aurp1.id)
      expect(assigns(:rule).projects.second.id).to eq(aurp2.id)
      expect(assigns(:rule).name).to eq(rule_to_copy.name + ' (copy)')
    end

    it "Copy an auto-update rule" do
      expect do
        post :copy, :params => {
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

    it "Copy an auto-update rule with project" do
        expect do
          post :copy, :params => {
            :auto_update_rule => { name: "Title of copy",
                  author_id: User.current.id,
                  project_ids: [aurp1.project_id, aurp2.project_id]
            },
            :id => rule_to_copy.id,
          }
        end.to change { AutoUpdateRule.count }.by(1)
        .and change { AutoUpdateRuleProject.count }.by(2)

        new_rule = AutoUpdateRule.last

        expect(response).to redirect_to(auto_update_rules_path)
        expect(new_rule.author_id).not_to eq(rule_to_copy.author_id)
        expect(new_rule.project_ids.first).to eq(aurp1.project_id)
        expect(new_rule.project_ids.second).to eq(aurp2.project_id)
        expect(new_rule.name).to eq('Title of copy')
    end
  end
end
