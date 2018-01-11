Rails.application.routes.draw do
  resources :event_videos
  resources :events
  resources :transactions,  only: [:new, :create]
  resources :user_accounts, only: [:update, :edit]
  devise_for :users, :controllers => { omniauth_callbacks: "omniauth_callbacks" } 
  root 'home#search_results'
  post '/add_to_cart' => "home#add_to_cart",as: :add_to_cart
  get '/add_to_cart' => "home#add_to_cart",as: :add_to_cart_after_sign_in
  get '/checkout' => "home#checkout",as: :checkout
  post '/pay' => "home#pay"
  get '/events/:event_id/videos' => "event_videos#show_event_videos",as: :show_event_videos
  get '/upload_video' => "event_videos#upload_video",as: :upload_video
  get '/purchases' => "home#purchases",as: :purchases
  get '/places' => "home#places",as: :places
  get '/search' => "home#search_results",as: :search
  get '/search_api' => "home#search_api",as: :search_api
  post '/save_video' => "event_videos#save_video",as: :save_video
  get '/event_videos/new/:event_id' => "event_videos#new",as: :event_video_event
  get '/save_static_camera' => "static_camera#new", as: :save_static_camera
  get '/delete_static_camera' => "static_camera#delete"
  post '/create_camera' => "static_camera#create", as: :create_camera
  post '/destroy_camera' => "static_camera#destroy"
  get '/report_spam' => "event_videos#report_spam"
  post '/update_spam' => "event_videos#update_spam"
  get '/subscribe/:event_id' => "events#subscribe", as: :subscribe_event
  get '/unsubscribe/:event_id' => "events#unsubscribe", as: :unsubscribe_event
  post '/remove_from_cart' => "home#remove_from_cart", as: :remove_from_cart
  post '/paypalNotification' =>"paypal#notification"
  get '/success' => "paypal#success"
  get '/execute' => "paypal#execute"
  get '/cancelled' => "paypal#cancelled"
  post '/setup_purchase' => "paypal#setup_purchase"

  get '/videos' => 'user_accounts#uploaded_videos'
  get '/user_events' => 'user_accounts#events'
  get '/cameras' => 'user_accounts#cameras'
  get '/payments' => 'user_accounts#payments'
  patch '/update_payment_info' => 'user_accounts#update_payment_info'

  get '/download' => "home#download_video"

end
