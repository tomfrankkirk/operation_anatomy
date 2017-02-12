Rails.application.routes.draw do

  # the root of the app -> straight to all questions 
  root 'users#index'

  # custom routes
  get '/respond', to: 'questions#respond'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  #automatic routes go here
  resources :questions
  resources :topics

end
