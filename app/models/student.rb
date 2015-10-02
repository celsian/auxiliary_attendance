class Student < ActiveRecord::Base
  require 'csv'

  validates :first_name, :last_name, :id_number, presence: true
  validates :id_number, uniqueness: true
  
  has_many :class_session_students
  has_many :class_sessions, through: :class_session_students

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|

      student = find_by(id_number: row["id_number"]) || Student.new

      student.attributes = row.to_hash.slice("id_number", "first_name", "last_name")

      student.save
    end #CSV
  end #def end.
end
