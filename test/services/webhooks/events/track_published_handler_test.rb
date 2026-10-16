require "test_helper"

class Webhooks::Events::TrackPublishedHandlerTest < ActiveSupport::TestCase
  setup do
    @meeting = MeetingRecording.create!(
      room_name: "test-room",
      status: "recording",
      started_at: Time.current
    )

    @event = {
      "event" => "track_published",
      "room" => { "name" => "test-room" },
      "participant" => { "identity" => "user-1" },
      "track" => {
        "sid" => "TR_test123",
        "source" => "MICROPHONE"
      }
    }
  end

  test "microphone track starts egress and saves egress id" do
    egress = Struct.new(:egress_id).new("EG_test123")

    recorder = Object.new
    recorder.define_singleton_method(:start) do |room_name:, track_sid:|
      raise "unexpected room" unless room_name == "test-room"
      raise "unexpected track" unless track_sid == "TR_test123"

      egress
    end

    with_recorder_stub(recorder) do
      Webhooks::Events::TrackPublishedHandler.new.call(@event)
    end

    recording = @meeting.participant_recordings.find_by!(
      track_sid: "TR_test123"
    )

    assert_equal "EG_test123", recording.egress_id
    assert_equal "recording", recording.status
    assert_equal "user-1", recording.participant_identity
  end

  test "non microphone track does not start egress" do
    @event["track"]["source"] = "CAMERA"

    recorder = Object.new
    recorder.define_singleton_method(:start) do |**_args|
      raise "Egress must not start"
    end

    with_recorder_stub(recorder) do
      Webhooks::Events::TrackPublishedHandler.new.call(@event)
    end

    assert_equal 0, @meeting.participant_recordings.count
  end

  test "egress failure marks recording as failed" do
    recorder = Object.new
    recorder.define_singleton_method(:start) do |**_args|
      raise "Egress API error"
    end

    with_recorder_stub(recorder) do
      assert_raises(RuntimeError) do
        Webhooks::Events::TrackPublishedHandler.new.call(@event)
      end
    end

    recording = @meeting.participant_recordings.find_by!(
      track_sid: "TR_test123"
    )

    assert_equal "failed", recording.status
    assert_equal "Egress API error", recording.error_message
  end

  private

  def with_recorder_stub(recorder)
    original_new = LivekitTrackRecorder.method(:new)

    LivekitTrackRecorder.define_singleton_method(:new) { recorder }
    yield
  ensure
    LivekitTrackRecorder.define_singleton_method(:new, original_new)
  end
end
