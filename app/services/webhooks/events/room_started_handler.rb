# frozen_string_literal: true

module Webhooks
  module Events
    class RoomStartedHandler
      def call(event)
        room_name = event.dig("room", "name")
        return if room_name.blank?

        MeetingRecording.find_or_create_by!(
          room_name: room_name,
          status: "recording"
        ) do |recording|
          recording.started_at = Time.current
        end
      end
    end
  end
end
