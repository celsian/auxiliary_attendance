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

  end
end
