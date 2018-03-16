Rails.application.routes.draw do
  namespace :v1, defaults: { format: :json } do
    get :user_details, to: 'users#details'
    resources :restaurants, only: [:index, :show] do
      get :autocomplete, on: :collection
    end
  end
end
