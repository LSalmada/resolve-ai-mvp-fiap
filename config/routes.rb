Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  get "up" => "rails/health#show", as: :rails_health_check

  authenticated :user do
    root "occurrences#index", as: :authenticated_root
  end

  devise_scope :user do
    unauthenticated do
      root "users/sessions#new"
    end
  end

  resources :occurrences, only: %i[index show new create] do
    resources :comments, only: :create
    resource :rating, only: :create
    member do
      patch :transition
      patch :assign
      patch :prioritize
    end
  end

  get "dashboard", to: "dashboard#show", as: :dashboard
end
