Rails.application.routes.draw do
  
   # devise routes
   devise_for :users

   resources :topics
   resources :systems 

   # custom routes
   get    '/teaching',                      to: 'teaching#show'

   post   '/questions',                     to: 'questions#respond'
   get    '/questions',                     to: 'questions#respond'
   get    '/static/about',                  to: 'static#about'     
   get    '/dictionary_entries',            to: 'dictionary_entries#index'
   get    '/dictionary_entries/define',     to: 'dictionary_entries#define'

   post   '/feedback',                      to: 'users#submitFeedback'
   get    '/questions_index',               to: 'questions#index'
   get    '/static/bugs',                   to: 'static#bugs' 

   get    '/users',                         to: 'users#index'
   get    '/users/:id',                     to: 'users#show', as: 'user'
   get    '/users/adminMode/:id',           to: 'users#adminMode'
   get    '/users/revisionMode/:id',        to: 'users#revisionMode'

   get    '/teaching/*path',                to: 'teaching#webRotateXML'
   
   # the root of the app -> straight to all topics
   root "systems#index"

end
