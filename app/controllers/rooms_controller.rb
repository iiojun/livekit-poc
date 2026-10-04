require "livekit"
class RoomsController < ApplicationController
  def show
  end

  def token
    identity = params[:identity]
    room_name = params[:room]

    if identity.blank? || room_name.blank?
      render json: { error: "identity and room are required" }, status: :bad_request
      return
    end

    token = LiveKit::AccessToken.new(
      api_key: ENV.fetch("LIVEKIT_API_KEY"),
      api_secret: ENV.fetch("LIVEKIT_API_SECRET")
    )

    token.identity = identity

    token.video_grant = LiveKit::VideoGrant.new(
      roomJoin: true,
      room: room_name,
      canPublish: true,
      canSubscribe: true,
      canPublishData: true
    )

    render json: {
      token: token.to_jwt,
      url: ENV.fetch("LIVEKIT_URL")
    }
  end
end
