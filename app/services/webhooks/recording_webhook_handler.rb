# frozen_string_literal: true

module Webhooks
  class RecordingWebhookHandler < LivekitWebhookHandler
    EVENT_HANDLERS = {
      "room_started" => Events::RoomStartedHandler,
      "track_published" => Events::TrackPublishedHandler,
      "room_finished" => Events::RoomFinishedHandler,
      "egress_ended" => Events::EgressEndedHandler
    }.freeze

    private
    def process_event(event)
      handler_class = EVENT_HANDLERS[event["event"]]
      return unless handler_class
      handler_class.new.call(event)
    end
  end
end
