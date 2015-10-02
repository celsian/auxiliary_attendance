class Student < ActiveRecord::Base
  require 'csv'

  validates :first_name, :last_name, :id_number, presence: true
  validates :id_number, uniqueness: true
  
  has_many :class_session_students
  has_many :class_sessions, through: :class_session_students

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
