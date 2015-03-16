class CreateClassSessionStudents < ActiveRecord::Migration
  def change
    create_table :class_session_students do |t|
      t.belongs_to :class_session, index: true
      t.belongs_to :student, index: true

      t.timestamps
    end
  end
end
