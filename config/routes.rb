Rails.application.routes.draw do
  namespace :v1, defaults: { format: :json } do
    post '/sessions' => "sessions#create"
    post '/sync'     => "base#sync"
    get '/me'        => 'base#me'

    resources :tables do
      collection { get 'search' }
      collection { get 'all' }
    end

    resources :users do
      collection { get 'search' }
      collection { get 'all' }
    end

    resources :outlets do
      collection { get 'search' }
      collection { get 'all' }
    end

    resources :products do
      collection { get 'search' }
      collection { get 'category' }
      collection { get 'all' }
    end

    resources :discounts do
      collection { get 'search' }
      collection { get 'all' }
    end
  end

  # catch not found
  devise_for :users
  match "*path", to: "errors#catch_404", via: :all
  root "errors#catch_404", default: { format: :json }
end
