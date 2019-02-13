Rails.application.routes.draw do
  root 'static_pages#home'
  get  '/help',    to: 'static_pages#help'
  # tutorial: can also rename it using 'as'
  #     For example:
  # get  '/help',    to: 'static_pages#help', as: "haha" ==> haha_path
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
end