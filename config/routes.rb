Rails.application.routes.draw do
  resources :music_videos

  resources :documents

  root 'home#index'
  
  resources :posts do
    member do
      get 'upload'
    end
  end
end
