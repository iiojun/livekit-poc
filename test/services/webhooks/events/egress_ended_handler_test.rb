
require "test_helper"

class Webhooks::Events::EgressEndedHandlerTest < ActiveSupport::TestCase
  setup do
    @meeting = MeetingRecording.create!(
      room_name: "test-room",
      status: "recording",
      started_at: Time.current
    )

    @recording = @meeting.participant_recordings.create!(
      participant_identity: "user-1",
      track_sid: "TR_test123",
      egress_id: "EG_test123",
      status: "recording",
      started_at: Time.current
    )
  end

  test "completed egress marks recording as uploaded" do
    event = {
      "event" => "egress_ended",
      "egressInfo" => {
        "egressId" => "EG_test123",
        "status" => "EGRESS_COMPLETE",
        "endedAt" => Time.current.to_i
      }
    }

    Webhooks::Events::EgressEndedHandler.new.call(event)

    @recording.reload

    assert_equal "uploaded", @recording.status
    assert_not_nil @recording.ended_at
    assert_nil @recording.error_message
  end

  test "failed egress saves error message" do
    event = {
      "event" => "egress_ended",
      "egressInfo" => {
        "egressId" => "EG_test123",
        "status" => "EGRESS_FAILED",
        "error" => "S3 upload failed"
      }
    }

    Webhooks::Events::EgressEndedHandler.new.call(event)

    @recording.reload

    assert_equal "failed", @recording.status
    assert_equal "S3 upload failed", @recording.error_message
    assert_not_nil @recording.ended_at
  end

  test "unknown egress id is ignored" do
    event = {
      "event" => "egress_ended",
      "egressInfo" => {
        "egressId" => "EG_unknown",
        "status" => "EGRESS_COMPLETE"
      }
    }

    assert_nothing_raised do
      Webhooks::Events::EgressEndedHandler.new.call(event)
    end

    assert_equal "recording", @recording.reload.status
  end
end

