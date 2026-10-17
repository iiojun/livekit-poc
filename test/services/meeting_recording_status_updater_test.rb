
require "test_helper"

class MeetingRecordingStatusUpdaterTest < ActiveSupport::TestCase
  setup do
    @meeting = MeetingRecording.create!(
      room_name: "test-room",
      status: "processing",
      started_at: Time.current,
      ended_at: Time.current
    )
  end

  test "all participant recordings uploaded changes meeting to completed" do
    create_participant_recording("user-1", "uploaded")
    create_participant_recording("user-2", "uploaded")

    MeetingRecordingStatusUpdater.call(@meeting)

    assert_equal "completed", @meeting.reload.status
  end

  test "any failed participant recording changes meeting to failed" do
    create_participant_recording("user-1", "uploaded")
    create_participant_recording("user-2", "failed")

    MeetingRecordingStatusUpdater.call(@meeting)

    assert_equal "failed", @meeting.reload.status
  end

  test "unfinished participant recordings keep meeting processing" do
    create_participant_recording("user-1", "uploaded")
    create_participant_recording("user-2", "recording")
    create_participant_recording("user-3", "pending")

    MeetingRecordingStatusUpdater.call(@meeting)

    assert_equal "processing", @meeting.reload.status
  end

  test "no participant recordings changes meeting to failed" do
    MeetingRecordingStatusUpdater.call(@meeting)

    assert_equal "failed", @meeting.reload.status
  end

  private

  def create_participant_recording(identity, status)
    @meeting.participant_recordings.create!(
      participant_identity: identity,
      track_sid: "TR_#{identity}",
      status: status
    )
  end
end

