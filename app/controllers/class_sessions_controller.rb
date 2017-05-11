class ClassSessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_teacher

  def index
    if current_user
      ClassSession.active_class_count > 0 ? flash[:info] = ClassSession.count_notification : ""
      ClassSession.stale_classes?

      @class_sessions_open = ClassSession.where(user: current_user, closed: false)[0..ClassSession::PAGINATION_SIZE]
      @class_sessions_closed = ClassSession.where(user: current_user, closed: true)
      @pages = @class_sessions_closed.count/ClassSession::PAGINATION_SIZE

      if params[:cc]
        pagination_values = ClassSession.pagination params[:cc]
        start = pagination_values.first
        finish = pagination_values.last

        @class_sessions_closed = @class_sessions_closed[start..finish]
      else
        params[:cc] = 0
        @class_sessions_closed = @class_sessions_closed[0..ClassSession::PAGINATION_SIZE]
      end
    end
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
      flash[:error] = "<B>ERROR:</B> #{errors}"
      render :new
    end
  end

  def edit
    @class_session = ClassSession.find(params[:id])
  end

  def update
    @class_session = ClassSession.find(params[:id])
    if @class_session.update_attributes(class_session_params)
      redirect_to class_session_path(@class_session), flash: {success: "Session was updated."}
    else
      flash[:error] = "<B>ERROR:</B> #{errors}"
      render :edit
    end
  end

  def close_session
    @class_session = ClassSession.find(params[:id])

    time = Time.now

    @class_session.class_session_students.where(end_time: nil).each do |class_session_student|
      class_session_student.end_time = class_session_student.start_time
      class_session_student.save
    end

    @class_session.close

    redirect_to class_sessions_path
  end

  def destroy

  end

  private

  def errors
    errors = ""
    @class_session.errors.full_messages.each do |message|
      errors += (" " + message + ".")
    end

    errors
  end

  def class_session_params
    params.require(:class_session).permit(:name)
  end

  def require_teacher
    unless current_user.teacher == true
      redirect_to root_path, flash: { error: "You are not authorized to perform that action." }
    end
  end

end
