Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }
  root to: "pages#home"
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :podcasts
      resources :episodes, only: [:create, :update]
      resources :crm_items, only: [:index, :create]
      resources :themes, only: [:update]
      get "dashboard", to: "podcasts#dashboard"
      get "dashboard/:id", to: "podcasts#dashboard_single"
      patch "dashboard/edit", to: "podcasts#update"
      get "landing/:subdomain", to: "podcasts#landing_page"
      get "landing/:subdomain/:id", to: "podcasts#landing_page_single_episode"
      post "uploadaudio", to: "episodes#upload_audio_for_transcription"
      get "gettranscription", to: "episodes#download_transcription"
      get "fetch_instagram/:podcast_id", to: "podcasts#fetch_instagram"
    end
  end

  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => "/sidekiq"
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
