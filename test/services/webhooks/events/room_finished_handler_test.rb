
require "test_helper"

class Webhooks::Events::RoomFinishedHandlerTest < ActiveSupport::TestCase
  setup do
    @meeting = MeetingRecording.create!(
      room_name: "test-room",
      status: "recording",
      started_at: Time.current
    )

    @event = {
      "event" => "room_finished",
      "room" => { "name" => "test-room" }
    }
  end

  test "room finished changes meeting to processing when egress is pending" do
    @meeting.participant_recordings.create!(
      participant_identity: "user-1",
      track_sid: "TR_test123",
      status: "recording",
      started_at: Time.current
    )

    Webhooks::Events::RoomFinishedHandler.new.call(@event)

    assert_equal "processing", @meeting.reload.status
  end

  test "room finished changes meeting to completed when all recordings are uploaded" do
    @meeting.participant_recordings.create!(
      participant_identity: "user-1",
      track_sid: "TR_test123",
      status: "uploaded",
      started_at: Time.current
    )

    Webhooks::Events::RoomFinishedHandler.new.call(@event)

    assert_equal "completed", @meeting.reload.status
  end

  test "room finished changes meeting to failed when a recording has failed" do
    @meeting.participant_recordings.create!(
      participant_identity: "user-1",
      track_sid: "TR_test123",
      status: "failed",
      started_at: Time.current
    )

    Webhooks::Events::RoomFinishedHandler.new.call(@event)

    assert_equal "failed", @meeting.reload.status
  end
end

