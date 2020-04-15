Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :podcasts
      get 'dashboard', to: 'podcasts#show'
      patch 'dashboard/edit', to: 'podcasts#update'
      get "landing/:subdomain", to: "podcasts#landing_page"
      get "uploadaudio", to: "podcasts#upload_audio_for_transcription"
      get "gettranscription", to: "podcasts#download_transcription"
    end
  end
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
