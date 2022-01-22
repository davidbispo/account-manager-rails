Rails.application.routes.draw do
  post '/strategies', to: 'events#create'
end
