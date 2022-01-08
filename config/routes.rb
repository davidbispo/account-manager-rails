Rails.application.routes.draw do
  post '/events', to: 'events#create'
end
