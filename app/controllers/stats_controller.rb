class StatsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_teacher

  def index

  end

  def general
    offset = 0

    if params[:offset]
      offset = params[:offset].to_i
    end

    @class_sessions = ClassSession.where("created_at >= :day_start AND created_at <= :day_end",
                                          {
                                            day_start: (Time.zone.now+offset.days).beginning_of_day,
                                            day_end: (Time.zone.now+offset.days).end_of_day
                                          }
                                        )

    @class_sessions_week = ClassSession.unscoped.where(created_at: 1.week.ago..1.second.ago)
    @class_sessions_month = ClassSession.unscoped.where(created_at: 1.month.ago..1.second.ago)


  end

  private

  def require_admin_or_teacher
    unless current_user.admin == true || current_user.teacher == true
      redirect_to root_path, flash: { error: "You are not authorized to perform that action." }
    end
  end
end
