class ClassSessionsController < ApplicationController
  def index
    if current_user
      @class_sessions_open = ClassSession.where(user: current_user, closed: false)
      @class_sessions_closed = ClassSession.where(user: current_user, closed: true)
    end
    # binding.pry
  end

  def show
    @class_session = ClassSession.find(params[:id])
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
    @class_session.close

    redirect_to class_sessions_path
  end

  def destroy

  end

  private

  def class_session_params
    params.require(:class_session).permit(:name)
  end

end
