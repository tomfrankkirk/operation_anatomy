Rails.application.routes.draw do

  devise_for :users
  # the root of the app -> straight to all topics
  root 'topics#index'

  # custom routes
  post   '/questions',            to: 'questions#respond'
  get    '/questions',            to: 'questions#respond'
  get    '/topics',               to: 'topics#index'
  get    '/topics/:id',           to: 'topics#show', as: 'topic'
  get    '/teaching',             to: 'teaching#show'
  get    '/teaching/:id/:id',     to: 'teaching#assetRequest'
  get    '/teaching/define',      to: 'teaching#define'

  # automatic routes go here


end
