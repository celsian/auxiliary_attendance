class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :class_sessions

  default_scope { order("email ASC") }

  USERS_PER_PAGE = 10.0

  def error_messages
    messages = ""
    errors.full_messages.each do |message|
      messages += message + "."
    end
    messages
  end

  def self.search query, page_index
    query = query.downcase
    result = where(sanitize_sql_array(["email LIKE :query", query: "%#{query}%"]))
    result_count = result.count
    result = result[(User.page page_index)..-1]
    return [result_count, result[0..USERS_PER_PAGE-1]]
  end

  def self.page page_index
    USERS_PER_PAGE*page_index.to_i
  end

  def self.teachers page_index
    teachers = User.where(teacher: true)
    teachers = teachers[(User.page page_index)..-1]
    teachers[0..USERS_PER_PAGE-1]
  end

  def self.admins page_index
    admins = User.where(admin: true)
    admins = admins[(User.page page_index)..-1]
    admins[0..USERS_PER_PAGE-1]
  end

  def formatted_email
    if email.length > 50
      return email[0..(50-(email.length-email.index("@")))]+"..."+email[email.index("@")..-1]
    else
      return email
    end
  end

  def self.teacher_count
    return User.where(teacher: true).count
  end

  def self.admin_count
    return User.where(admin: true).count
  end

  def self.user_pages user_count
    (user_count/USERS_PER_PAGE).ceil
  end

  def self.teacher_pages
    (User.teacher_count/USERS_PER_PAGE).ceil
  end

  def self.admin_pages
    (User.admin_count/USERS_PER_PAGE).ceil
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

  def self.calendar_weeks_start month
    results = User.calendar month
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
    results = User.calendar month
    class_session.where(start_time: results[:month_start]..results[:month_end])
  end
#####End Calendar Calculations########
end
