Rails.application.routes.draw do
  root "rooms#show"
  post "token", to: "rooms#token"
end
