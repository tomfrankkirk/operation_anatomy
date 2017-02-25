Rails.application.routes.draw do

  devise_for :users
  # the root of the app -> straight to all users.  
  root 'topics#index'

  # custom routes
  get    '/questions',  to: 'questions#respond'
  post   '/questions',  to: 'questions#respond'
  get    '/topics',     to: 'topics#index'
  get    '/topics/:id', to: 'topics#show', as: 'topic'
  get    '/teaching',   to: 'teaching#show'

  #automatic routes go here
  # resources :topics

end
