Snpr::Application.routes.draw do
  resources :static
  resources :phenotypes
  resources :genotypes
  resources :user_phenotypes
  resources :snps
  resources :users
  resource :user_session
  resources :user_snps
  resources :password_resets
  resources :news
  resources :messages
  resources :snp_comments
  resources :phenotype_comments
  resources :search_results
	resources :achievements
	resources :user_achievements
	resources :index
  
  match '/signup', :to => 'users#new'
  match '/signin', :to => 'user_sessions#new', :as => :login
  match '/signout', :to => 'user_sessions#destroy', :as => :logout
  match '/faq', :to => 'static#faq'
  match '/user_index', :to => 'users#index'
  match '/rss', :to => 'genotypes#feed'
  match '/search', :to => 'search_results#search'
  match '/users/:id/remove_help_one', :to => 'users#remove_help_one'
  match '/users/:id/remove_help_two', :to => 'users#remove_help_two'
  match '/users/:id/remove_help_three', :to => 'users#remove_help_three'
  match '/phenotypes/get_genotypes/:phenotype_id/:variation', :to => 'phenotypes#get_genotypes'
  match '/phenotypes/:id/rss', :to => 'phenotypes#feed'
  
  root :to => 'index#index' # change thisi, maybe
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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
