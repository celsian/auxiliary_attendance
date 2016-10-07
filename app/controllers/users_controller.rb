class UsersController < ApplicationController
  def user_search
    if params[:q] && params[:q].blank? || !params[:q]
      params[:q] = "@"
    end
    results = User.search(params[:q], params[:s])
    @users = results.last
    @user_pages = User.user_pages(results.first)

    @teachers = User.teachers(params[:t])
    @teacher_pages = User.teacher_pages
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    final_params = {}

    if user_params[:password] == ""
      final_params[:email] = user_params[:email]
    else
      final_params = user_params
    end

    if @user.update final_params
      redirect_to user_search_path, flash: { success: "#{@user.email} has been updated." }
    else
      redirect_to edit_user_path(@user), flash: { error: "Error: #{@user.error_messages}" }
    end
  end

  def teacher_stats_search
    if params[:q] && params[:q].blank? || !params[:q]
      params[:q] = ""
    end
    results = User.teacher_search(params[:q], params[:s])
    @teachers = results.last
    @teacher_pages = (results.first/User::USERS_PER_PAGE).ceil
  end

  def teacher_stats
    @teacher = User.find(params[:id])
    @months = @teacher.class_session_timeline

    if @teacher.class_sessions.length > 0
      if params[:m]
        @current_month = params[:m].to_time
      else
        @current_month = @months.first
      end
        @current_month_calendar = User.calendar @current_month
        @current_month_sessions = @teacher.class_sessions_for_month_results @current_month
        @weeks = User.calendar_weeks_start @current_month
        @current_month_total_time = User.time_monthly @current_month_sessions
        @weekly_times = @teacher.time_weekly @weeks
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
