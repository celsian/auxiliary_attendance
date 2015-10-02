class ClassSessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_teacher

  def index
    if current_user
      @class_sessions_open = ClassSession.where(user: current_user, closed: false)
      @class_sessions_closed = ClassSession.where(user: current_user, closed: true)
    end
    # binding.pry
  end

  def show
    @class_session = ClassSession.find(params[:id])
    @class_session_student = ClassSessionStudent.new
  end

  def new
    @class_session = ClassSession.new
  end

  def create
    @class_session = ClassSession.new(class_session_params)
    @class_session.user = current_user

    if @class_session.save
      redirect_to class_session_path(@class_session), flash: {success: "Session was created."}
    else
      errors = ""
      @class_session.errors.full_messages.each do |message|
        errors += (" " + message + ".")
      end

      flash[:error] = "<B>ERROR:</B> #{errors}"
      render :new
    end
  end

  def close_session
    @class_session = ClassSession.find(params[:id])

    time = Time.now

    @class_session.class_session_students.where(end_time: nil).each do |class_session_student|
      class_session_student.end_time = time
      class_session_student.save
    end

    @class_session.close

    redirect_to class_sessions_path
  end

  def destroy

  end

  private

  def class_session_params
    params.require(:class_session).permit(:name)
  end

  def require_teacher
    unless current_user.teacher == true
      redirect_to root_path, flash: { error: "You are not authorized to perform that action." }
    end
  end

end
