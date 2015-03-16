class ClassSessionStudent < ActiveRecord::Base
  belongs_to :class_session
  belongs_to :student
end
