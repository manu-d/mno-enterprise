MnoEnterprise::Engine.routes.draw do
  
  #============================================================
  # Static Pages
  #============================================================
  root to: "application#index"
  
  #============================================================
  # Devise Configuration
  #============================================================
  devise_for :users, { 
    class_name: "MnoEnterprise::User",
    module: :devise, 
    path_prefix: 'auth' 
  }
  
  #============================================================
  # JPI V1
  #============================================================
  namespace :jpi do
    namespace :v1 do
      resources :marketplace, only: [:index,:show]
      resource :current_user, only: [:show]
      
      resources :organizations, only: [:index, :show, :update] do
        member do
          put :invite_members
          put :update_member
          put :remove_member
        end
        
        resources :app_instances, only: [:index]
      end
    end
  end
end
