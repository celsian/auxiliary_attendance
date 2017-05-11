class WelcomeController < ApplicationController
  def index
    if current_user
      ClassSession.active_class_count > 0 ? flash[:info] = Welcome.count_notification : ""
      if current_user.teacher
        redirect_to class_sessions_path
      elsif current_user.admin
        redirect_to admin_index_path
      end
    end
  end

end
