class CreateParticipantRecordings < ActiveRecord::Migration[8.0]
  def change
    create_table :participant_recordings do |t|
      t.references :meeting_recording,
        null: false,
        foreign_key: true

      t.string :participant_identity, null: false
      t.string :track_sid
      t.string :egress_id
      t.string :status, null: false, default: "pending"

      t.datetime :track_published_at
      t.datetime :started_at
      t.datetime :ended_at
      t.text :error_message

      t.timestamps
    end

    add_index :participant_recordings,
      [:meeting_recording_id, :status],
      name: "index_participant_recordings_on_meeting_and_status"

    add_index :participant_recordings,
      :egress_id,
      unique: true,
      where: "egress_id IS NOT NULL",
      name: "index_participant_recordings_on_egress_id"

    add_check_constraint :participant_recordings,
      "status IN ('pending', 'recording', 'uploaded', 'processing', 'completed', 'failed')",
      name: "participant_recordings_status_check"
  end
end
