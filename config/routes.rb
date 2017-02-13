Rails.application.routes.draw do

  # the root of the app -> straight to all questions 
  root 'users#index'

  # custom routes
  get '/respond', to: 'questions#respond'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  get    '/questions', to: 'questions#respond'
  post   '/questions', to: 'questions#respond'

  #automatic routes go here
  resources :topics

end
