Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  root to: 'home#index'
  resources :watches, except: :show do
    member do
      post :borrowing
    end
  end

  resources :borrows, only: [:index, :create, :destroy] do
    member do
      patch :approve
      patch :reject
    end
  end

  get 'watch/lending', to: 'borrows#lending', as: 'lending'
  get 'watch/:watch_id/image/:id', to: 'images#download', as: 'image_download'
end
