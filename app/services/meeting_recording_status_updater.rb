# frozen_string_literal: true

class MeetingRecordingStatusUpdater
  def self.call(meeting_recording)
    new(meeting_recording).call
  end

  def initialize(meeting_recording)
    @meeting_recording = meeting_recording
  end

  def call
    @meeting_recording.with_lock do
      # 会議終了後の処理だけを対象にする
      next unless @meeting_recording.status == "processing"

      recordings = @meeting_recording.participant_recordings

      # 録音が1件もない場合は失敗とする
      if recordings.none?
        @meeting_recording.update!(status: "failed")
      elsif recordings.where(status: "failed").exists?
        @meeting_recording.update!(status: "failed")
      elsif recordings.where.not(status: "uploaded").exists?
        # まだ処理中の録音がある
        next
      else
        @meeting_recording.update!(status: "completed")
      end
    end
  end
end
