class Student < ActiveRecord::Base
  require 'csv'

  validates :first_name, :last_name, :id_number, presence: true
  validates :id_number, uniqueness: true

  has_many :class_session_students
  has_many :class_sessions, through: :class_session_students

  default_scope { order("first_name ASC") }

  PAGINATION_SIZE = 8

  def error_messages
    messages = ""
    errors.full_messages.each do |message|
      messages += message + "."
    end
    messages
  end

  def self.student_pages student_count
    (student_count/User::USERS_PER_PAGE).ceil
  end
######Calendar Calculations#######
  def class_session_timeline
    all_months = []

    class_sessions_results = class_sessions.reorder(created_at: :desc)

    if class_sessions_results.length > 0
    #   start_month = class_sessions_results.first.created_at.at_beginning_of_month
    #   end_month = class_sessions_results.last.created_at.at_beginning_of_month

    #   unless end_month == start_month
    #     all_months << end_month
    #     end_month = end_month-1.month
    #   end

    #   all_months << start_month
      class_sessions_results.each do |cs|
        current_month = cs.created_at.at_beginning_of_month
        if all_months.last != current_month
          all_months << current_month
        end
      end

      return all_months
    end

    return nil
  end

  def self.calendar month
    results = {}
    results[:month_start] = calendar_start month
    results[:month_end] = calendar_end month
    results
  end

  def self.calendar_weeks_start month
    results = Student.calendar month
    current_week = results[:month_start]
    weeks = []

    while current_week.to_s != (results[:month_end]+1.second).to_s
      weeks << current_week
      current_week+=7.days
    end

    weeks
  end

  def self.calendar_start month
    month_start = month.at_beginning_of_month
    month_start-(month_start.wday).days
  end

  def self.calendar_end month
    month_end = month.at_end_of_month
    month_end+(6-month_end.wday).days
  end

  def class_sessions_for_month_results month
    results = Student.calendar month
    class_session_students.where(start_time: results[:month_start]..results[:month_end])
  end
#####End Calendar Calculations########

  def self.search query, page_index, enabled_bool
    if query != ""
      query = query.downcase
      result = where(sanitize_sql_array(["lower(first_name) LIKE :query OR lower(last_name) LIKE :query OR id_number like :query", query: "%#{query}%"])).where(enabled: enabled_bool)
    else
      result = Student.where(enabled: enabled_bool)
    end
    result_count = result.count
    result = result[(Student.page page_index)..-1]
    return [result_count, result[0..User::USERS_PER_PAGE-1]]
  end

  def self.page page_index
    User::USERS_PER_PAGE*page_index.to_i
  end

  def self.student_pages user_count
    (user_count/User::USERS_PER_PAGE).ceil
  end

  def self.to_bool bool
    if bool == "0"
      return false
    else
      return true
    end
  end

  def time_weekly weeks
    week_minutes = []

      weeks.each do |week_start|
        time = 0
        class_session_students.where(start_time: week_start..(week_start+7.days)).each do |css|
          if css.end_time
            time += css.end_time - css.start_time
          else
            time += Time.now - css.start_time
          end
        end
        week_minutes << (time/60)
      end

      formatted_time = []

      week_minutes.each do |min|
        time = {}
        time[:hours] = (min/60).floor
        time[:minutes] = (min%60).round
        formatted_time << time
      end

    return formatted_time
  end

  def self.time_monthly class_session_student_array
    total_seconds = 0
    class_session_student_array.each do |cs|
      if cs.end_time
        total_seconds += cs.end_time - cs.start_time
      end
    end

    time = {}
    time[:hours] = (total_seconds/60/60).floor
    time[:minutes] = ((total_seconds%3600)/60).round
    return time
  end

  def self.import(file)
    enabled_students = Student.where(enabled: "1")
    student_list = []
    record_changes = {success: 0, failure: 0}

    CSV.foreach(file.path, headers: true) do |row|

      student = find_by(id_number: row["id_number"]) || Student.new

      student.attributes = row.to_hash.slice("id_number", "first_name", "last_name")
      student.enabled = true

      if student.save
        record_changes[:success] += 1
        student_list << student
      else
        record_changes[:failure] += 1
      end
    end #CSV

    disable_students = enabled_students - student_list

    if disable_students.length > 0
      disable_students.each do |student|
          student.enabled = false
          student.save
      end
    end

    return record_changes
  end #def end.

  def self.attendance_hash
    count_hash = {"5+" => 0, "1-4" => 0, "0" => 0}
    student_count = {}

    ClassSession.unscoped.where(created_at: 1.week.ago..1.second.ago).each do |cs|
      cs.students.distinct.each do |student|
        student_count[student.id_number] ||= 0
        student_count[student.id_number] += 1
      end
    end

    student_count.each do |k, v|
      if v >= 5
        count_hash["5+"] += 1
      else
        count_hash["1-4"] += 1
      end
    end

    count_hash["0"] = Student.where(enabled: true).count-(count_hash["5+"]+count_hash["1-4"])

    count_hash

    # Student.where(enabled: true).each do |student|
    #   count = student.class_sessions.where(created_at: 1.week.ago..Time.now).count
    #   if count >= 5
    #     count_hash["5+"] += 1
    #   elsif count > 0 && count <= 4
    #     count_hash["1-4"] += 1
    #   else
    #     count_hash["0"] += 1
    #   end
    # end
  end

  def self.unique_students_last_week
    student_count = {}

    ClassSession.unscoped.where(created_at: 1.week.ago.beginning_of_week..1.week.ago.end_of_week).each do |cs|
      cs.students.distinct.each do |student|
        student_count[student.id_number] ||= 0
        student_count[student.id_number] += 1
      end
    end

    student_count.length
  end

  def self.unique_students_this_week
    student_count = {}

    ClassSession.unscoped.where(created_at: 1.second.ago.beginning_of_week..1.second.ago.end_of_week).each do |cs|
      cs.students.distinct.each do |student|
        student_count[student.id_number] ||= 0
        student_count[student.id_number] += 1
      end
    end

    student_count.length
  end
end
