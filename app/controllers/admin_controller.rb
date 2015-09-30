class AdminController < ApplicationController
  def index

  end

  def teacher_editor
    if params[:q] && params[:q].blank? || !params[:q]
      params[:q] = "@"
    end
    results = User.search(params[:q], params[:s])
    @users = results.last
    @user_pages = User.user_pages(results.first)

    @teachers = User.teachers(params[:t])
    @teacher_pages = User.teacher_pages
  end  

  def add_teacher
    user = User.find(params[:id])
    user.teacher = true
    if user.save
      redirect_to teacher_editor_path(q: params[:q]), flash: { success: "#{user.email} is now a Teacher." }
    else
      flash[:error] = "Error: There was a problem adding the rights."
      render :add_teacher
    end
  end

  def remove_teacher
    user = User.find(params[:id])
    user.teacher = false
    if user.save
      redirect_to teacher_editor_path(q: params[:q]), flash: { success: "#{user.email} is no longer a Teacher." }
    else
      flash[:error] = "Error: There was a problem adding the rights."
      render :add_teacher
    end
  end

  def admin_editor

  end
end
