class StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  skip_before_action :require_admin, only: [:stats_search, :stats]
  before_action :require_admin_or_teacher

  def index
    if params[:q] && params[:q].blank? || !params[:q]
      params[:q] = ""
    end

    results = Student.search(params[:q], params[:s], Student.to_bool(params[:enabled]))

    @student_pages = Student.student_pages(results.first)
    @students = results.last
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new(student_params)

    if @student.save
      redirect_to students_path, flash: {success: "Student was created."}
    else
      flash[:error] = "Error: #{@student.error_messages}"
      render :new
    end
  end

  def stats_search
    if params[:q] && params[:q].blank? || !params[:q]
      params[:q] = ""
    end
    results = Student.search(params[:q], params[:s], true)
    @students = results.last
    @student_pages = Student.student_pages(results.first)

  end

  def stats
    @student = Student.find(params[:id])
    @months = @student.class_session_timeline

    if @student.class_sessions.length > 0
      if params[:m]
        @current_month = params[:m].to_time
      else
        @current_month = @months.first
      end
        @current_month_calendar = Student.calendar @current_month
        @current_month_sessions = @student.class_sessions_for_month_results @current_month
        @weeks = Student.calendar_weeks_start @current_month
        @current_month_total_time = Student.time_monthly @current_month_sessions
        @weekly_times = @student.time_weekly @weeks
    end
  end

  def edit
    @student = Student.find(params[:id])
    if @student.enabled
      @student_action_word = "Disable"
      @student_action_class = "danger"
    else
      @student_action_word = "Enable"
      @student_action_class = "success"
    end
  end

  def update
    @student = Student.find(params[:id])
    if @student.update student_params
      redirect_to students_path, flash: {success: "Student was updated."}
    else
      flash[:error] = "Error: #{@student.error_messages}"
      render :edit
    end
  end

  def enable_disable
    @student = Student.find(params[:id])

    @student.enabled = !@student.enabled
    if @student.save
      @student.enabled ? action_word = "enabled" : action_word = "disabled"
      redirect_to students_path, flash: {success: "Student with ID ##{@student.id_number} has been #{action_word}."}
    end
  end

  def disable
    @student = Student.find(params[:id])
    @student.enabled = false
    if @student.save
      redirect_to students_path, flash: {success: "Student with ID ##{@student.id_number} is disabled."}
    end
  end

  def import
    if params[:file]
      record_changes = Student.import(params[:file])
      redirect_to import_path, flash: {success: "#{record_changes[:success]} Students were imported or updated. #{record_changes[:failure]} failed."}
    end
  end

  private

  def student_params
    params.require(:student).permit(:first_name, :last_name, :id_number)
  end

  def require_admin
    unless current_user.admin == true
      redirect_to root_path, flash: { error: "You are not authorized to perform that action." }
    end
  end

  def require_admin_or_teacher
    unless current_user.admin == true || current_user.teacher == true
      redirect_to root_path, flash: { error: "You are not authorized to perform that action." }
    end
  end
end