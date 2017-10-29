require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'verify' => 'verification#show'

      match '*path', to: 'base#routing_error', via: :all
    end
  end
end
