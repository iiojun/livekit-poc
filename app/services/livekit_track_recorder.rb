# frozen_string_literal: true

require "livekit"

class LivekitTrackRecorder
  def initialize
    @client = LiveKit::EgressServiceClient.new(
      ENV.fetch("LIVEKIT_API_URL"),
      api_key: ENV.fetch("LIVEKIT_API_KEY"),
      api_secret: ENV.fetch("LIVEKIT_API_SECRET")
    )
  end

  def start(room_name:, track_sid:)
    output = LiveKit::Proto::DirectFileOutput.new(
      filepath: "dialogbook/{room_name}/{track_id}.ogg",
      s3: LiveKit::Proto::S3Upload.new(
        access_key: ENV.fetch("R2_ACCESS_KEY_ID"),
        secret: ENV.fetch("R2_SECRET_ACCESS_KEY"),
        endpoint: ENV.fetch("R2_ENDPOINT"),
        bucket: ENV.fetch("R2_BUCKET"),
        region: ENV.fetch("R2_REGION"),
        force_path_style: true
      )
    )

    @client.start_track_egress(room_name, output, track_sid)
  end
end
