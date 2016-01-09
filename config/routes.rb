Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/super_admin', as: 'rails_admin'
  apipie
  get '/manager', :to => redirect('/manager/index.html')
  get '/kitchen', :to => redirect('/kitchen/index.html')

  namespace :v1, defaults: { format: :json } do
    post '/sessions' => "sessions#create"
    post '/sync'     => "base#sync"
    get '/me'        => 'base#me'

    get 'prints/bill'
    get 'prints/send_bill_to_email'
    get 'prints/send_receipt_to_email'
    get 'prints/reprint'
    get 'prints/receipt'
    get 'prints/recap'

    get '/users/:id/rekap' => 'users#rekap'

    post '/syncs/import_from_cloud' => 'syncs#import_from_cloud'
    post '/syncs/export_from_local' => 'syncs#export_from_local'
    post '/syncs/import_from_cloud' => 'syncs#import_from_cloud'
    post '/syncs/import_from_local' => 'syncs#import_from_local'

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
      collection { post 'authorize_for_oc' }
      collection { get 'attendances' }
      collection { put 'come_out' }
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
      collection { get 'get_by_tenant' }
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
      collection { get 'get_by_tenant' }
      collection { get 'get_top_foods' }
      collection { get 'get_top_drinks' }
      collection { get 'get_order_quantity' }
    end

    resources :discounts do
      collection { get 'search' }
      collection { get 'all' }
    end

    resources :orders do
      collection { get 'search' }
      collection { get 'all' }
      collection { get 'waiting_orders' }
      collection { get 'history_orders' }
      collection { post 'from_servant' }
      collection { post 'unlock' }
      member { post 'pay_order' }
      member { post 'make_order' }
      member { post 'print_order' }
      member { put 'toggle_served' }
      member { put 'toggle_pantry' }
      collection { get 'graph_by_revenue' }
      collection { get 'graph_by_order' }
      collection { get 'graph_by_pax' }
      collection { get 'graph_by_tax' }
      collection { get 'get_order_quantity' }

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
      collection { post 'void_items' }
      collection { post 'oc_items' }
    end

    resources :payments do
      collection { get 'search' }
      collection { get 'all' }
      member { post 'void_item' }
      collection { get 'print_bill' }
    end

    resources :printers do
      collection { get 'search' }
      collection { get 'all' }
    end

    resources :voids do
      collection { get 'search' }
    end

    resources :officer_checks do
      collection { get 'search' }
    end
  end

  # catch not found
  devise_for :users
  match "*path", to: "errors#catch_404", via: :all
  root "errors#catch_404", default: { format: :json }
end
