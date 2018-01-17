class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

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
      render :teacher_editor
    end
  end

  def remove_teacher
    user = User.find(params[:id])
    user.teacher = false
    if user.save
      redirect_to teacher_editor_path(q: params[:q]), flash: { success: "#{user.email} is no longer a Teacher." }
    else
      flash[:error] = "Error: There was a problem adding the rights."
      render :teacher_editor
    end
  end

  def add_peer_tutor
    user = User.find(params[:id])
    user.peer_tutor = true
    if user.save
      redirect_to teacher_editor_path(q: params[:q]), flash: { success: "#{user.email} is now a Peer Tutor." }
    else
      flash[:error] = "Error: There was a problem adding the rights."
      render :teacher_editor
    end
  end

  def remove_peer_tutor
    user = User.find(params[:id])
    user.peer_tutor = false
    if user.save
      redirect_to teacher_editor_path(q: params[:q]), flash: { success: "#{user.email} is no longer a Peer Tutor." }
    else
      flash[:error] = "Error: There was a problem adding the rights."
      render :teacher_editor
    end
  end

  def admin_editor
    if params[:q] && params[:q].blank? || !params[:q]
      params[:q] = "@"
    end
    results = User.search(params[:q], params[:s])
    @users = results.last
    @user_pages = User.user_pages(results.first)

    @admins = User.admins(params[:a])
    @admin_pages = User.admin_pages
  end

  def add_admin
    user = User.find(params[:id])
    user.admin = true

    if user.save
      redirect_to admin_editor_path(q: params[:q]), flash: { success: "#{user.email} is now an Administrator." }
    else
      flash[:error] = "Error: There was a problem adding the rights."
      render :admin_editor
    end
  end

  def remove_admin
    user = User.find(params[:id])
    user.admin = false
    if user.save
      redirect_to admin_editor_path(q: params[:q]), flash: { success: "#{user.email} is no longer an Administrator." }
    else
      flash[:error] = "Error: There was a problem adding the rights."
      render :admin_editor
    end
  end

  private

  def require_admin
    unless current_user.admin == true
      redirect_to root_path, flash: { error: "You are not authorized to perform that action." }
    end
  end
end