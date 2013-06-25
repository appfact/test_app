TestApp::Application.routes.draw do

  resources :users do
    member do
      get :user_remove_network
    end
  end

  resources :sessions, only: [:new, :create, :destroy]
  
  resources :shifts, only: [:create, :destroy, :show, :update] do
    member do
      get :requests
      get :offers
      get :remove_worker
      get :assign
      get :assign_worker
      get :approve_request
      get :edit
      get :clone
      get :series
      get :dais
      get :dsis
      get :rais
      get :rsis
      get :ais
      get :ais_to_worker
      get :offer_shift_to_worker
      get :unoffer_shift_to_worker
    end
  end

  resources :firms do
    member do
      get :network
      get :shiftrequests
      get :rufn
      get :shifts
      get :schedules
      get :permissions
      get :stats
      get :makeadmin
      get :removeadmin
      get :edit
    end
  end

  resources :firm_permissions
  
  resources :shift_requests do
    member do
      get :offerdestroy
      get :cancelrequest
      get :rejectoffer
      get :acceptoffer
    end
  end

  match '/home', to: 'static_pages#home', via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  match '/signup', to: 'users#new'
  match '/signupuser', to: 'users#newuser'
  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete
  match '/shifts', to: 'users#shifts', via: 'get'
  match '/shift_requests', to: 'shift_requests#index', via: 'get'
  match '/invite', to: 'users#invite'
  match '/pastshifts', to: 'users#pastshifts', via: 'get'
  match '/allshifts', to: 'users#allshifts', via: 'get'
  match '/availableshifts', to: 'users#availableshifts', via: 'get'
  match '/offers', to: 'users#offers', via: 'get'
  match '/requests', to: 'users#requests', via: 'get'
  match '/schedule', to: 'users#schedule', via: 'get'
  match '/user_request_from_available_shifts', to: 'shift_requests#user_request_from_available_shifts', via: 'get'
  match '/cancel_request_from_available_shifts', to: 'shift_requests#cancel_request_from_available_shifts', via: 'get'
  match '/switchtoadmin', to: 'users#switch_from_user_to_admin', via: 'get'
  match '/switchtononadmin', to: 'users#switch_to_non_admin', via: 'get'
  match '/switchbusiness', to: 'users#switch_business_account', via: 'get'
  match '/newshift', to: 'shifts#newshift', via: 'get'
  match '/newshiftclone', to: 'shifts#newshiftclone', via: 'get'

  
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
