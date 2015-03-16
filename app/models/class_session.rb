class ClassSession < ActiveRecord::Base
  belongs_to :user
  has_many :class_session_students
  has_many :students, through: :class_session_students

  validates :name, presence: true

  def close
    self.closed = true
    self.end_time = Time.now
    self.save
  end
end
