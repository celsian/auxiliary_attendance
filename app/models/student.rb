class Student < ActiveRecord::Base
  require 'csv'

  validates :first_name, :last_name, :id_number, presence: true
  validates :id_number, uniqueness: true
  
  has_many :class_session_students
  has_many :class_sessions, through: :class_session_students

  default_scope { order("first_name ASC") }

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
