class Student < ActiveRecord::Base
  has_many :class_session_students
  has_many :class_sessions, through: :class_session_students
end
