class WelcomeController < ApplicationController
  def index
    if current_user
      if current_user.teacher
        redirect_to class_sessions_path
      end
    end
  end
  
end
