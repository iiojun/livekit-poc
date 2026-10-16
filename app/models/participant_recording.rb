class ParticipantRecording < ApplicationRecord
  belongs_to :meeting_recording

  has_one_attached :audio_file

  STATUSES = %w[
    pending recording uploaded processing completed failed
  ].freeze

  validates :participant_identity, presence: true
  validates :status, presence: true
end
