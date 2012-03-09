Migratorator::Application.routes.draw do

  get 'mappings/find' => 'mappings#show', :as => :mapping
  resources :mappings, :except => [:show]

end
