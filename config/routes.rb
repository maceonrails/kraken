Rails.application.routes.draw do
  namespace :v1, defaults: { format: :json } do
    post '/sessions' => "sessions#create"
    get '/me' => 'base#me'

    resources :tables
    resources :users
  end

  # catch not found
  devise_for :users
  match "*path", to: "errors#catch_404", via: :all
  root "errors#catch_404", default: { format: :json }
end
