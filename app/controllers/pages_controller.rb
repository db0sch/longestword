require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def game
    @grid = generate_grid(9)
    @start_time = Time.now
  end

  def score
    @attempt = params[:attempt]
    @grid = params[:grid]
    @start_time = Time.parse(params[:start])
    @end_time = Time.now
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end


  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    rand_letters = []
    grid_size.times do
      rand_letters << ('A'..'Z').to_a[rand(26)]
      # essayer de mettre plus de voyelle dans le grid !
    end
    rand_letters
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    result = {
      time: 0,
      translation: nil,
      score: 0,
      message: "you didn't type a word"
    }
    return result if attempt == ""
    result[:time] = end_time - start_time

    if compare_grid(grid, attempt)
      result[:translation] = call_api_wordref(attempt)
      if result[:translation].nil?
        result[:message] = "not an english word"
        return result
      end
      result[:score] = score_calc(attempt.size, result[:time])
      result[:message] = message_score(result[:score])
    else
      result[:score] = 0
      result[:message] = "not in the grid"
    end
    result
  end


  def call_api_wordref(attempt)
    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"
    open(api_url) do |trad|
      quote = JSON.parse(trad.read)
      if quote["Error"] == "NoTranslation"
        return nil
      else
        return quote["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
      end
    end
  end

  def score_calc(letter_score, time)
    score_final = letter_score

    if time < 10
      score_final += 1
    else
      score_final -= time.fdiv(10).truncate
    end
    score_final
  end

  def message_score(score)
    message = {
      average: "Pas mal !!",
      good: "well done"
    }
    if score <= 5
      return message[:average]
    else
      return message[:good]
    end
  end

  def compare_grid(grid, attempt)
    attempt.upcase.split('').all? do |x|
      attempt.upcase.split('').count(x) <= grid.count(x)
    end
  end
end
