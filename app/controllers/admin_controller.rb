class AdminController < ApplicationController
  def index

  end

  def teacher_editor
    if params[:q] && params[:q].blank? || !params[:q]
      params[:q] = "@"
    end
    @users = User.search(params[:q])
    @teachers = User.where(teacher: true)
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
