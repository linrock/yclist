Yclist::Application.routes.draw do

  root :to => 'companies#index'

  get '/dynamic' => 'companies#dynamic'

  get '/edit' => 'companies#edit'
  post '/update' => 'companies#update'

end
