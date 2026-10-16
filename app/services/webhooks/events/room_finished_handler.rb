# frozen_string_literal: true

module Webhooks
  module Events
    class RoomFinishedHandler
      def call(event)
        room_name = event.dig("room", "name")
        return if room_name.blank?

        recording = MeetingRecording.find_by(
          room_name: room_name,
          status: "recording"
        )
        return unless recording

        recording.update!(
          status: "processing",
          ended_at: Time.current
        )
      end
    end
  end
end
