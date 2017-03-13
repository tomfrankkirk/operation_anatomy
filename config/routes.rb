Rails.application.routes.draw do

  devise_for :users
  # the root of the app -> straight to all topics
  root 'topics#index'

  # custom routes
  get    '/teaching',             to: 'teaching#show'
  get    '/images/:id',           to: 'teaching#fetchImage'
  get    '/teaching/define',      to: 'teaching#define'
  post   '/questions',            to: 'questions#respond'
  get    '/questions',            to: 'questions#respond'
  get    '/topics',               to: 'topics#index'
  get    '/topics/:id',           to: 'topics#show', as: 'topic'

end
