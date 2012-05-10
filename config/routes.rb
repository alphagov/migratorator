Migratorator::Application.routes.draw do

  get 'mappings(/filter/:tags)' => 'mappings#index', :as => :filter_mappings, :constraints => { :tags => /.+/ }
  get 'mappings/find' => 'mappings#show', :as => :find_mapping

  resources :mappings, :tags

  root :to => "root#index"

end