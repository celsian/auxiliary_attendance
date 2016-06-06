class StatsController < ApplicationController
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
  end
end
