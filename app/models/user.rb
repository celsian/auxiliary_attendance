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
end
