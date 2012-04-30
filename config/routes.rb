Migratorator::Application.routes.draw do

  get 'mappings(/filter/:tags)' => 'mappings#index', :as => :filter_mappings, :constraints => { :tags => /.+/ }
  get 'mappings/find' => 'mappings#show', :as => :find_mapping
  resources :mappings

  root :to => "mappings#index"

end
