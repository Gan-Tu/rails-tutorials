Rails.application.routes.draw do
  get 'users/new'

  root 'static_pages#home'

  # tutorial: can also rename it using 'as'
  #     For example:
  # get  '/help',    to: 'static_pages#help', as: "haha" ==> haha_path
  
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'

  get "/signup",   to: 'users#new'
  post '/signup',  to: 'users#create'

  resources :users
end