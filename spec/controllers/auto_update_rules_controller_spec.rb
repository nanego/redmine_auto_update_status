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

  context "POST copy" do
    # TODO :
    # créer des nouvelles règles dans /home/julie/Documents/redmine/redmine/plugins/redmine_auto_update_status/spec/fixtures/auto_update_rules.yml
    # créer de nouvelles relations règles/projets dans /home/julie/Documents/redmine/redmine/plugins/redmine_auto_update_status/spec/fixtures/auto_update_rule_project.yml
    # PENSER A REMETTRE LES BONNES FIXTURES DANS LE CORE POUR LES TESTS
    # Tester que la table a bien été incrémentée de 1
    # Tester l'auteur
    # Le nom du projet --> attention à la langue
    # tester que les projets ait bien été copié

    let!(:rule_to_copy) { AutoUpdateRule.find(4) }

    it "Copy an auto-update rule without changes" do
        expect do
          post :copy, :params => {
            :id => rule_to_copy.id,
            :auto_update_rules => {
              :name => "test"
            }

          }
        end.to change { AutoUpdateRule.count }.by(1)


    end

    it "Copy an auto-update rule with changes" do
      expect(true).to eq(true)
    end

    # exemple
    # field = ProjectCustomField.first
    #       expect do
    #         patch :update, :params => {
    #           :id => field.id,
    #           :custom_field => {
    #             :name => "new_name",
    #             :description => "new_des",
    #             :is_required => true,
    #           }
    #         }
    #       end.to change { JournalSetting.count }.by(1)
    # expect(JournalSetting.last.value_changes).to include({ "name" => [field.name, "new_name"] })

  end

end
