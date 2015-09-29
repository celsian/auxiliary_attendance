class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :class_sessions

  def self.search query
    query = query.downcase
    where("email LIKE :query", query: "%#{query}%")
  end

  def formatted_email
    if email.length > 50
      return email[0..(50-(email.length-email.index("@")))]+"..."+email[email.index("@")..-1]
    else
      return email
    end
  end
end
