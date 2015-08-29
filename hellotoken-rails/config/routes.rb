Rails.application.routes.draw do

  # devise routes (i.e.  logging in and signing up)
  devise_for :publishers, controllers: { registrations: "publishers/registrations", confirmations: 'confirmations', sessions: 'sessions'}
  devise_for :researchers, controllers: { registrations: "researchers/registrations", confirmations: 'confirmations', sessions: 'sessions'}

  # popup routes, mainly for ajax posting
  get 'popup/index'
  get 'popup/demo', to: "popup#index", mode: "demo"
  post 'popup/submit'
  get 'popup/ping'
  get 'popup/check', to: "popup#checkPublisherID"

  # home page routes (esp. for those not signed in yet)
  get "index", to: "hellotoken#index"
  get "login", to: "hellotoken#login"
  get "register", to: "hellotoken#register"
  get "thanks", to: "hellotoken#thanks"
  get "confirm", to: "hellotoken#confirm"
  get "contact", to: "hellotoken#contact"
  get "about", to: "hellotoken#about"
  get "faq", to: "hellotoken#faq"
  get "terms", to: "hellotoken#terms"
  get "bestpractices", to: "hellotoken#bestpractices"
  # get "waiting", to: "hellotoken#waiting"

  # various static pages (e.g. exception, confirmation, about) pages
  # get "hellotoken/order"
  get "invalid", to: "hellotoken#invalid"
  get "invitation", to: "hellotoken#invitation"

  # pages for those signed in (esp. dealing with researchers and question creation)
  get "dashboard", to: "dashboard#index" # aliases of the main dashboard
  get "researcher_dashboard", to: "dashboard#index"
  get "publisher_dashboard", to: "dashboard#index"
  get "payout", to: "dashboard#payout" #, constraints: { protocol: 'https://', host: 'paypalurl' } -- I'll implement this soon
  get "waiting", to: "dashboard#waiting"
  get "researcher_waiting", to: "dashboard#waiting"
  get "publisher_waiting", to: "dashboard#waiting"
  get "plugin", to: "dashboard#download_plugin"
  post "purchase", to: "campaigns#purchase"
  post "save_campaign", to: "campaigns#save_session"
  resources :campaigns 

  resources :questions, :choices

  # admin pages
  get "admin", to: "hellotoken#admin"
  get "logs", to: "hellotoken#logs"

  # resources
  resources :readers, :responses, :articles, :researchers, :publishers

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  # You can have the root of your site routed with "root"
  root "hellotoken#index"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
