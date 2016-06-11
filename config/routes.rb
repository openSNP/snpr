require 'sidekiq/web'

Snpr::Application.routes.draw do
  root :to => 'index#index' # change this, maybe

  resources :static
  resources :updates
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

  post '/fitbit/notification/', :to => 'fitbit_profiles#new_notification'
  get '/fitbit/start_auth', :to => 'fitbit_profiles#start_auth'
  get '/fitbit/verify', :to => 'fitbit_profiles#verify_auth'
  get '/fitbit/info', :to => 'fitbit_profiles#info'
  get '/fitbit/edit', :to => 'fitbit_profiles#edit'
  get '/fitbit/init', :to => 'fitbit_profiles#init'
  post '/fitbit/update/', :to => 'fitbit_profiles#update'
  get '/fitbit/delete/', :to => 'fitbit_profiles#destroy'
  get '/fitbit/show/:id', :to => 'fitbit_profiles#show', :as => :fitbit_show
  get '/fitbit/dump/:id', :to => 'fitbit_profiles#dump', :as => :fitbit_dump
  get '/fitbit/', :to => 'fitbit_profiles#index', :as => :fitbit_index
  get '/phenotypesets/enter/:id', :to => "phenotype_sets#enter_userphenotypes"
  get '/phenotypesets/user_phenotypes/save', :to => "phenotype_sets#save_user_phenotypes"
  get '/users/:id/changepassword', :to => 'users#changepassword'
  get '/signup', :to => 'users#new', as: :signup
  get '/signin', :to => 'user_sessions#new', :as => :login
  get '/signout', :to => 'user_sessions#destroy', :as => :logout
  get '/faq', :to => 'static#faq'
  get '/disclaimer', :to => 'static#disclaimer'
  get '/statistics', :to => 'static#statistics'
  get '/user_index', :to => 'users#index'
  get '/rss', :to => 'genotypes#feed', :as => :feed, :defaults => {:format => 'rss' }
  get '/search', :to => 'search_results#search'
  get '/users/:id/remove_help_one', :to => 'users#remove_help_one'
  get '/users/:id/remove_help_two', :to => 'users#remove_help_two'
  get '/users/:id/remove_help_three', :to => 'users#remove_help_three'
  get '/phenotypes/get_genotypes/:phenotype_id/:variation', :to => 'phenotypes#get_genotypes'
  get 'get_dump', :to => 'genotypes#get_dump'
  get '/phenotypes/:id/rss', :to => 'phenotypes#feed', :defaults => { :format => 'rss' }
  get '/dump_download', :to => 'genotypes#dump_download'
  get '/snps/json/annotation/:snp_name', :to => 'snps#json_annotation'
  get '/snps/json/:snp_name/:user_id', :to => 'snps#json'
  get '/phenotypes/json/variations/:phenotype_id', :to => 'phenotypes#json_variation'
  get '/phenotypes/json/:user_id', :to => 'phenotypes#json'
  get '/das/:id/features', :to => 'das#show'
  get '/das/sources', :to => 'das#sources'
  get '/das/:id/', :to => 'das#startpoint'
  get '/paper/rss', :to => 'news#paper_rss', :defaults => { :format => 'rss' }
  get '/recommend_phenotype/:id/', :to => 'phenotypes#recommend_phenotype'
  get '/press', :to => 'static#press'
  get '/blog' => redirect("http://opensnp.wordpress.com")
  get '/user_picture_phenotypes/:id/edit', :to => 'user_picture_phenotypes#edit'
  get '/user_picture_phenotypes/:id/delete', :to => 'user_picture_phenotypes#delete'
  get '/beacon/rest/responses', :to => 'beacon#responses'

  mount Sidekiq::Web => '/sidekiq'
end
