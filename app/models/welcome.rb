class Welcome
  def self.count_notification
    active_class_count = ClassSession.active_class_count
    active_student_count = ClassSessionStudent.active_student_count

    unless active_class_count == 0 && active_student_count == 0
      return "Welcome! There are currently #{active_student_count} #{'student'.pluralize(active_student_count)} in #{active_class_count} #{'class'.pluralize(active_class_count)}."
    else
      return ""
    end
  end
end