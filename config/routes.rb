Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :friend_ships
      resources :members do
        collection do
          post :add_friend
          get :get_friends
          get :get_experts
          get :delete_friend
        end	
      end
    end
  end
end