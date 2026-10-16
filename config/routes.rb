Rails.application.routes.draw do
  root "rooms#show"
  post "token", to: "rooms#token"
  post "/webhooks/livekit", to: "webhooks/livekit#create"
end
