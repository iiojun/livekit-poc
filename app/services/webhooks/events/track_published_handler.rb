# frozen_string_literal: true

module Webhooks
  module Events
    class TrackPublishedHandler
      def call(event)
        track = event["track"]
        return unless track&.dig("source") == "MICROPHONE"

        room_name = event.dig("room", "name")
        identity = event.dig("participant", "identity")
        track_sid = track["sid"]

        return if [room_name, identity, track_sid].any?(&:blank?)

        meeting = MeetingRecording.find_by!(
          room_name: room_name,
          status: "recording"
        )

        recording = meeting.participant_recordings
          .find_or_initialize_by(track_sid: track_sid)

        # Egress がすでに開始されているトラックは再処理しない
        return if recording.persisted? && recording.egress_id.present?

        recording.assign_attributes(
          participant_identity: identity,
          status: "pending",
          track_published_at: recording.track_published_at || Time.current,
          error_message: nil
        )
        recording.save!

        begin
          egress = LivekitTrackRecorder.new.start(
            room_name: room_name,
            track_sid: track_sid
          )

          recording.update!(
            egress_id: egress.egress_id,
            status: "recording",
            started_at: Time.current
          )
        rescue StandardError => e
          recording.update!(
            status: "failed",
            error_message: e.message
          )
          raise
        end
      end
    end
  end
end
