Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Con resources podemos definir todos loe métodos de un recurso
  resources :posts, only: [:index, :show]
end
