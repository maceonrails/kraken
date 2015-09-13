Rails.application.routes.draw do
  apipie
  namespace :v1, defaults: { format: :json } do
    post '/sessions' => "sessions#create"
    post '/sync'     => "base#sync"
    get '/me'        => 'base#me'

    resources :tables do
      collection { get 'search' }
      collection { get 'all' }
      collection { get 'locations' }
      collection { post 'linking' }
      collection { post 'moving' }
      member { put 'change' }
    end

    resources :users do
      collection { get 'search' }
      collection { get 'all' }
      collection { post 'authorize_for_discount' }
      collection { post 'authorize_for_void' }
    end

    resources :outlets do
      collection { get 'search' }
      collection { get 'all' }
      collection { get 'get' }
    end

    resources :product_categories do
      resources :product_sub_categories do
        resources :products do
          collection { get 'get_by_sub_category' }
          collection { get 'search' }
          collection { get 'category' }
          collection { get 'all' }
        end
        collection { get 'search' }
        collection { get 'all' }
      end
      collection { get 'search' }
      collection { get 'all' }
    end

    resources :product_sub_categories do
      resources :products do
        collection { get 'search' }
        collection { get 'category' }
        collection { get 'all' }
      end
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

    resources :orders do
      collection { get 'search' }
      collection { get 'all' }
      collection { get 'waiting_orders' }
      collection { post 'from_servant' }
      member { post 'pay_order' }
      member { post 'make_order' }
      member { post 'void_order' }
      member { post 'void_item' }
      member { post 'print_order' }
      collection { get 'graph_by_revenue' }
      collection { get 'graph_by_order' }

      member { get 'get' }
      member { get 'print' }
      resources :order_items do
        collection { get 'search' }
        collection { get 'all' }
        collection { get 'active_items' }
      end
    end

    resources :order_items do
      collection { get 'search' }
      collection { get 'all' }
      member { put 'toggle_served'}
      collection { get 'active_items' }
    end

    resources :payments do
      collection { get 'search' }
      collection { get 'all' }
    end

    resources :printers do
      collection { get 'search' }
      collection { get 'all' }
    end
  end

  # catch not found
  devise_for :users
  match "*path", to: "errors#catch_404", via: :all
  root "errors#catch_404", default: { format: :json }
end
