Pykhub::Application.routes.draw do
  
  #root
  root :to => 'static_pages#index'

  # general
  post '/login', to: "users#login", as: "login"
  
end