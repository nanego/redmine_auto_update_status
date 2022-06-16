RedmineApp::Application.routes.draw do
  resources :auto_update_rules do
    member do
      post :apply
    end
  end
  match 'auto_update_rules/:id/copy', :controller => 'auto_update_rules', :action => 'new', :via => [:get, :post] , :as => 'copy_auto_update_rule'

end
