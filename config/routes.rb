Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post 'locations/distance'
  post 'locations/driver'
  post 'locations/address'

  resources :locations

end
