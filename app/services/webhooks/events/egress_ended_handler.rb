# frozen_string_literal: true

module Webhooks
  module Events
    class EgressEndedHandler
      SUCCESS_STATUSES = %w[EGRESS_COMPLETE].freeze
      FAILURE_STATUSES = %w[EGRESS_FAILED EGRESS_ABORTED].freeze

      def call(event)
        info = event["egressInfo"] || {}
        egress_id = info["egressId"]
        return if egress_id.blank?

        recording = ParticipantRecording.find_by(egress_id: egress_id)
        return unless recording

        status = info["status"].to_s
        if SUCCESS_STATUSES.include?(status)
          recording.update!(
            status: "uploaded",
            ended_at: Time.current,
            error_message: nil
          )
        elsif FAILURE_STATUSES.include?(status)
          recording.update!(
            status: "failed",
            ended_at: Time.current,
            error_message: info["error"].presence || status
          )
        else
          Rails.logger.warn(
            "[LiveKit Egress] Unexpected status=#{status} " \
            "egress_id=#{egress_id}"
          )
          return
        end

        MeetingRecordingStatusUpdater.call(recording.meeting_recording)
      end
    end
  end
end
