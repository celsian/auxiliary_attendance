class Student < ActiveRecord::Base
  require 'csv'

  validates :first_name, :last_name, :id_number, presence: true
  validates :id_number, uniqueness: true
  
  has_many :class_session_students
  has_many :class_sessions, through: :class_session_students

  default_scope { order("first_name ASC") }

  def error_messages
    messages = ""
    errors.full_messages.each do |message|
      messages += message + "."
    end
    messages
  end

######Calendar Calculations#######
  def class_session_timeline
    all_months = []

    class_sessions_results = class_sessions.reorder(created_at: :asc)
    if class_sessions_results.length > 0
      start_month = class_sessions_results.first.created_at.at_beginning_of_month
      end_month = class_sessions_results.last.created_at.at_beginning_of_month

      unless end_month == start_month
        all_months << end_month
        end_month = end_month-1.month
      end

      all_months << start_month

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

  # def self.calendar_weeks month
  #   results = calendar month
  #   ((results[:month_end] - results[:month_start])/(24 * 60 * 60)).ceil/7
  # end

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
    query = query.downcase
    result = where(sanitize_sql_array(["lower(first_name) LIKE :query OR lower(last_name) LIKE :query OR id_number like :query", query: "%#{query}%"])).where(enabled: enabled_bool)
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

  def self.import(file)
    record_changes = {success: 0, failure: 0}
    CSV.foreach(file.path, headers: true) do |row|

      student = find_by(id_number: row["id_number"]) || Student.new

      student.attributes = row.to_hash.slice("id_number", "first_name", "last_name")

      if student.save
        record_changes[:success] += 1
      else
        record_changes[:failure] += 1
      end
    end #CSV
    return record_changes
  end #def end.
end
