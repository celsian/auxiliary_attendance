class ClassSession < ActiveRecord::Base
  belongs_to :user
  has_many :class_session_students
  has_many :students, through: :class_session_students

  validates :name, presence: true

  default_scope { order("created_at desc") }

  def close
    self.closed = true
    self.end_time = Time.now
    self.save
  end

  def self.stale_classes?
    stale_classes = ClassSession.where("closed = ? AND created_at < ?", false, 9.hours.ago)

    stale_classes.each do |class_session|
      class_session.auto_close
    end
  end

  def class_session_students_sorted
    class_session_students.sort_by { |class_session_student| [class_session_student.student.last_name, class_session_student.student.first_name] }
  end

  def auto_close
    time = created_at #Initializing this incase no students signed out. (Should be when the last student left)

    class_session_students.each do |css|
      if css.start_time && css.start_time > time
        time = css.start_time
      end
      if css.end_time && css.end_time > time
        time = css.end_time
      end
    end

    class_session_students.where(end_time: nil).each do |class_session_student|
      class_session_student.end_time = class_session_student.start_time
      class_session_student.save
    end

    self.closed = true
    self.end_time = time
    self.save
  end
end
