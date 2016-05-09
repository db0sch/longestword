require 'game'

class PagesController < ApplicationController

  def game
    @grid = generate_grid(9)
    @start_time = Time.now
    @total = session[:total].nil? ? session[:total] = 0 : session[:total]
  end

  def score
    @attempt = params[:attempt]
    @grid = params[:grid].split('')
    @start_time = Time.parse(params[:start])
    @result = run_game(@attempt, @grid, @start_time, Time.now)
    @total = session[:total] += @result[:score]
  end
end