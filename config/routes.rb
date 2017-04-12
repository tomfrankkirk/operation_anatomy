Rails.application.routes.draw do
  
  # the root of the app -> straight to all topics
  root "topics#index"

  # devise routes
  devise_for :users

  # custom routes
  get    '/teaching',             to: 'teaching#show'
  get    '/images/:id',           to: 'teaching#fetchImage'
  get    '/teaching/define',      to: 'teaching#define'
  post   '/questions',            to: 'questions#respond'
  get    '/questions',            to: 'questions#respond'
  get    '/topics',               to: 'topics#index'
  get    '/topics/:id',           to: 'topics#show', as: 'topic'
  get    '/dictionary_entries',   to: 'dictionary_entries#index'
  post   '/feedback',             to: 'users#submitFeedback'
  get    '/questions_index',      to: 'questions#index'
  get    '/users',                to: 'users#index'
  get    '/users/:id',            to: 'users#show', as: 'user'
  get    '/static/bugs',          to: 'static#bugs' 
  get    '/teaching/*path',         to: 'teaching#webRotateXML'

end
