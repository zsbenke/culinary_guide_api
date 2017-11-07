Rails.application.routes.draw do
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      get :user_details, to: 'users#details'
    end
  end
end
