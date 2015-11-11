Yclist::Application.routes.draw do

  root :to => 'companies#index'

  get '/dynamic' => 'companies#dynamic'

end
