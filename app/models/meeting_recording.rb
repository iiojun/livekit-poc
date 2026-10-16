class MeetingRecording < ApplicationRecord
  has_many :participant_recordings,
           dependent: :destroy

  validates :room_name, presence: true
  validates :status, presence: true
end
