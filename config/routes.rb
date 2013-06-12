TestApp::Application.routes.draw do

  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  
  resources :shifts, only: [:create, :destroy, :show] do
    member do
      get :requests
      get :offers
      get :remove_worker
    end
  end

  resources :firms do
    member do
      get :network
    end
  end

  resources :firm_permissions
  
  resources :shift_requests do
    member do
      get :offerdestroy
    end
  end

  match '/home', to: 'static_pages#home', via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  match '/signup', to: 'users#new'
  match '/signupuser', to: 'users#newuser'
  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete
  match '/shifts', to: 'static_pages#shifts', via: 'get'
  match '/newshift', to: 'static_pages#newshift', via: 'get'
  match '/shift_requests', to: 'shift_requests#index', via: 'get'

  
  root to: 'static_pages#home'



  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
