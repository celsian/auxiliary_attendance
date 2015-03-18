class CreateClassSessionStudents < ActiveRecord::Migration
  def change
    create_table :class_session_students do |t|
      t.belongs_to :class_session, index: true
      t.belongs_to :student, index: true
      t.string :student_id_number
      t.string :reason
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end