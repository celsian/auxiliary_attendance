class ClassSessionStudent < ActiveRecord::Base
  belongs_to :class_session
  belongs_to :student

  validate :student_exists
  validate :class_session_open
  validate :student_unique_presence
  validates :reason, presence: true

  default_scope { order("created_at desc") }

  def student_exists
    if student_id == nil || (Student.find(student_id).enabled) == false
      if student_id == nil
        errors.add(:base, "Student \"#{student_id_number}\" does not exist.")
      else
        errors.add(:base, "Student \"#{student_id_number}\" is disabled, please contact an Administrator.")
      end
    end
  end

  def class_session_open
    if class_session.closed
      errors.add(:base, "Class session \"#{class_session.name}\" is not open.")
    end
  end

  def student_unique_presence
    if Student.exists?(id_number: student_id_number)
      if Student.find_by(id_number: student_id_number).class_session_students.count > 0

        most_recent_join_table = Student.find_by(id_number: student_id_number).class_session_students.first

        if most_recent_join_table.end_time == nil && most_recent_join_table.id != self.id
          errors.add(:base, "Student has not signed out of the previous class <b>\"#{most_recent_join_table.class_session.name}\"</b> with teacher <b>\"#{most_recent_join_table.class_session.user.email}\"</b>")
        end
      end
    end
  end

  def find_student
    return Student.find_by(id_number: student_id_number)
  end

  def self.director params
    student = Student.find_by(id_number: params[:student_id_number])
    if student
      if student.class_session_students.count > 0
        if student.class_session_students.first.class_session.id == params[:class_session_id].to_i && student.class_session_students.first.end_time == nil
          return "leave_session"
        end
      end
    end
  end

  def error_messages
    messages = ""
    errors.full_messages.each do |message|
      messages += message
    end
    messages
  end

end