class StatsController < ApplicationController
  def index
    
  end

  def general
    @class_sessions = ClassSession.where("created_at >= ?", Time.zone.now.beginning_of_day)
  end
end
