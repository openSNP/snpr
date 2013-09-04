Snpr::Application.routes.draw do
  root :to => 'index#index' # change this, maybe
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :static
  resources :phenotypes do
    member do
      get :feed
      get :get_genotypes
    end
  end
  resources :picture_phenotypes do
    member do
      get :feed
    end
  end
  resources :user_picture_phenotypes
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
  resources :picture_phenotype_comments
  resources :search_results
  resources :achievements
  resources :user_achievements
  resources :index

  match '/fitbit/notification/', :to => 'fitbit_profiles#new_notification'
  match '/fitbit/start_auth', :to => 'fitbit_profiles#start_auth'
  match '/fitbit/verify', :to => 'fitbit_profiles#verify_auth'
  match '/fitbit/info', :to => 'fitbit_profiles#info'
  match '/fitbit/edit', :to => 'fitbit_profiles#edit'
  match '/fitbit/init', :to => 'fitbit_profiles#init'
  match '/fitbit/update/', :to => 'fitbit_profiles#update'
  match '/fitbit/delete/', :to => 'fitbit_profiles#destroy'
  match '/fitbit/show/:id', :to => 'fitbit_profiles#show', :as => :fitbit_show
  match '/fitbit/dump/:id', :to => 'fitbit_profiles#dump', :as => :fitbit_dump
  match '/fitbit/', :to => 'fitbit_profiles#index', :as => :fitbit_index
  match '/phenotypesets/enter/:id', :to => "phenotype_sets#enter_userphenotypes"
  match '/phenotypesets/user_phenotypes/save', :to => "phenotype_sets#save_user_phenotypes"
  match '/users/:id/changepassword', :to => 'users#changepassword'
  match '/signup', :to => 'users#new', as: :signup
  match '/signin', :to => 'user_sessions#new', :as => :login
  match '/signout', :to => 'user_sessions#destroy', :as => :logout
  match '/faq', :to => 'static#faq'
  match '/disclaimer', :to => 'static#disclaimer'
  match '/user_index', :to => 'users#index'
  match '/rss', :to => 'genotypes#feed'
  match '/search', :to => 'search_results#search'
  match '/users/:id/remove_help_one', :to => 'users#remove_help_one'
  match '/users/:id/remove_help_two', :to => 'users#remove_help_two'
  match '/users/:id/remove_help_three', :to => 'users#remove_help_three'
  match '/phenotypes/get_genotypes/:phenotype_id/:variation', :to => 'phenotypes#get_genotypes'
  match 'get_dump', :to => 'genotypes#get_dump'
  match '/phenotypes/:id/rss', :to => 'phenotypes#feed'
  match '/dump_download', :to => 'genotypes#dump_download'
  match '/snps/json/annotation/:snp_name', :to => 'snps#json_annotation'
  match '/snps/json/:snp_name/:user_id', :to => 'snps#json'
  match '/phenotypes/json/variations/:phenotype_id', :to => 'phenotypes#json_variation'
  match '/phenotypes/json/:user_id', :to => 'phenotypes#json'
  match '/das/:id/features', :to => 'das#show'
  match '/das/sources', :to => 'das#sources'
  match '/das/:id/', :to => 'das#startpoint'
  match '/paper/rss', :to => 'news#paper_rss'
  match '/recommend_phenotype/:id/', :to => 'phenotypes#recommend_phenotype'
  match '/press', :to => 'static#press'
  match '/blog' => redirect("http://opensnp.wordpress.com")
  match '/user_picture_phenotypes/:id/edit', :to => 'user_picture_phenotypes#edit'
  match '/user_picture_phenotypes/:id/delete', :to => 'user_picture_phenotypes#delete'
  

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
