Migratorator::Application.routes.draw do

  get '/mappings(/filter/:tags)/page/:page' => 'mappings#index', :as => :paginated_filter_mappings, :constraints => { :tags => /([^.])+/ }
  get '/mappings(/filter/:tags)' => 'mappings#index', :as => :filter_mappings, :constraints => { :tags => /([^.])+/ }
  get '/mappings/find' => 'mappings#show', :as => :find_mapping

  get '/browser(/:tags)' => 'browser#index', :as => :browser, :constraints => { :tags => /[^.]+/ }

  resources :mappings, :tags

  root :to => "root#index"

end