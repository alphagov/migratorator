Migratorator::Application.routes.draw do

  get '/mapping' => 'mappings#show', :as => :mapping

end
