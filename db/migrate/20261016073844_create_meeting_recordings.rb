class CreateMeetingRecordings < ActiveRecord::Migration[8.0]
  def change
    create_table :meeting_recordings do |t|
      t.string :room_name, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :started_at
      t.datetime :ended_at
      t.text :error_message

      t.timestamps
    end

    add_index :meeting_recordings, [:room_name, :created_at]

    add_check_constraint :meeting_recordings,
      "status IN ('pending', 'recording', 'processing', 'completed', 'failed')",
      name: "meeting_recordings_status_check"
  end
end
