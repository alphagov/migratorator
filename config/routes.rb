Migratorator::Application.routes.draw do

  get '/route.json' => 'routes#show', :as => :route

end
