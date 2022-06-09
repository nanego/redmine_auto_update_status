RedmineApp::Application.routes.draw do
  resources :auto_update_rules do
    member do
      post :apply
    end
  end
  match 'auto_update_rules/copy/:id', :controller => 'auto_update_rules', :action => 'copy', :via => [:get, :post] , :as => 'copy_auto_update_rule'
end
