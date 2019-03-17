Rails.application.routes.draw do
  get 'password_resets/new'

  get 'password_resets/edit'

  root 'static_pages#home'

  # tutorial: can also rename it using 'as'
  #     For example:
  # get  '/help',    to: 'static_pages#help', as: "haha" ==> haha_path
  
  get     '/help',        to: 'static_pages#help'
  get     '/about',       to: 'static_pages#about'
  get     '/contact',     to: 'static_pages#contact'
  get     '/signup',      to: 'users#new'
  post    '/signup',      to: 'users#create'
  get     '/login',       to: 'sessions#new'
  post    '/login',       to: 'sessions#create'
  delete  '/logout',      to: 'sessions#destroy'

  resources :users
  # automatically generates:
  #     users GET    /users(.:format)                        users#index
  #           POST   /users(.:format)                        users#create
  #  new_user GET    /users/new(.:format)                    users#new
  # edit_user GET    /users/:id/edit(.:format)               users#edit
  #      user GET    /users/:id(.:format)                    users#show
  #           PATCH  /users/:id(.:format)                    users#update
  #           PUT    /users/:id(.:format)                    users#update
  #           DELETE /users/:id(.:format)                    users#destroy
  
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

end
