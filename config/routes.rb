Rails.application.routes.draw do
  post '/strategies', to: 'events#create'
  get '/acounts:id/balance', to: 'accounts#get_balance'
end
