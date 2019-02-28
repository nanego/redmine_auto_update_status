RedmineApp::Application.routes.draw do
  resources :auto_update_rules do
    member do
      post :apply
    end
  end
end
