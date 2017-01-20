Rails.application.routes.draw do
  resources :regions
  resources :instance_types
  resources :machine_types
  resources :providers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
