Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :podcasts
      resources :episodes, only: [:create, :update]
      get 'dashboard', to: 'podcasts#dashboard'
      get 'dashboard/:id', to: 'podcasts#dashboard_single'
      patch 'dashboard/edit', to: 'podcasts#update'
      get "landing/:subdomain", to: "podcasts#landing_page"
      get "landing/:subdomain/:id", to: "podcasts#landing_page_single_episode"
      get "uploadaudio", to: "podcasts#upload_audio_for_transcription"
      get "gettranscription", to: "podcasts#download_transcription"
      get "fetch_instagram", to: "podcasts#fetch_instagram"
    end
  end
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
