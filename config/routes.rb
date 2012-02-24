Migratorator::Application.routes.draw do

  get '/route' => 'routes#show', :as => :route

end
