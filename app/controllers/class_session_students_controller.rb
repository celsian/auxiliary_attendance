class ClassSessionStudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_teacher

  def director
    action = ClassSessionStudent.director(class_session_student_params)
    if action == "leave_session"
      leave_session
    else
      join_session
    end
  end

  def join_session
    session[:return_to] ||= request.referer

    @class_session_student = ClassSessionStudent.new class_session_student_params
    @class_session_student.start_time = Time.now
    @class_session_student.student = @class_session_student.find_student

    if @class_session_student.save
      flash[:success] = "#{@class_session_student.student.first_name} #{@class_session_student.student.last_name} has joined the session."
      redirect_to session.delete(:return_to)
    else
      flash[:error] = "Error: #{@class_session_student.error_messages}"
      redirect_to session.delete(:return_to)
    end
  end

  def leave_session
    session[:return_to] ||= request.referer

    @class_session_student = Student.find_by(id_number: class_session_student_params[:student_id_number]).class_session_students.first

    if @class_session_student.update_attributes(end_time: Time.now)
      flash[:success] = "#{@class_session_student.student.first_name} #{@class_session_student.student.last_name} has left the session."
      redirect_to session.delete(:return_to)
    else
      flash[:error] = "Error: #{@class_session_student.error_messages}"
      redirect_to session.delete(:return_to)
    end
  end

  def self.active_student_count
    ClassSessionStudent.where(end_time: nil).count
  end

  private

  def class_session_student_params
    params.require(:class_session_student).permit(:id, :class_session_id, :student_id, :student_id_number, :reason)
  end

  def require_teacher
    unless current_user.teacher == true
      redirect_to root_path, flash: { error: "You are not authorized to perform that action." }
    end
  end
end
