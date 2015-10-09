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

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
