require 'bundler'
Bundler.require
require 'sinatra/reloader' 

require_relative 'info'

Dotenv.load
class MainApp < Sinatra::Base

  get '/' do
    
    @grade = params['grade'] 
    @deparment = params['deparment']
    @num = params['num']
    @date = params['date']
    @sort = params['sort']

    @grade ||= ""
    @deparment ||= ""
    @num ||= ""
    @date ||= ""
    @sort ||= ""

    @info = QKbot::DB.all
    if @grade != "" then
      @info.select! do |info|
        info.grade == @grade.to_i
      end
    end
    if @deparment != "" then
      @info.select! do |info|
        info.department.include?(@deparment) || info.department.empty?
      end
    end
    if @num != "" then
      @info.select! do |info|
        info.num == @num.to_i || info.num == 0
      end
    end
    if @date != "" then
      @info.select! do |info|
        info.date.strftime("%Y-%m-%d") == @date
      end
    end
    
    case @sort
    when 'date' then
      @info.sort! do |a,b|
        a.date <=> b.date
      end
      @sort = '日付'
    when 'grade' then
      @info.sort! do |a,b|
        a.grade <=> b.grade
      end
      @sort = '学年'
    else
      @sort = 'なし'
    end
    
    haml :index
  end
end
