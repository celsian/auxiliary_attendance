class WelcomeController < ApplicationController
  def index
    ClassSession.stale_classes?
    
    if current_user
      if current_user.teacher
        redirect_to class_sessions_path
      elsif current_user.admin
        redirect_to admin_index_path
      end
    end
  end
  
end
