require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def game
    @grid = grid
    @start_time = Time.now
  end

  def grid
  grid_array = []
  10.times { grid_array << [*'A'..'Z'].sample }
  grid_array
  end

  def score
    start = params[:start_time]
    @end = Time.now
    @word = params[:query]
    @lucky_letters = params[:the_grid]
    @score = run_game(@word, @lucky_letters, start, @end)
  end

def included?(guess, grid)
  guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
end

def compute_score(attempt, time_taken)
  time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end

def run_game(attempt, grid, start_time, end_time)
  result = { time: end_time.to_time - start_time.to_time }

  score_and_message = score_and_message(attempt, grid, result[:time])
  result[:score] = score_and_message.first
  result[:message] = score_and_message.last

  result
end

def score_and_message(attempt, grid, time)
  if included?(attempt.upcase, grid)
    if english_word?(attempt)
      score = compute_score(attempt, time)
      [score, "well done"]
    else
      [0, "#{attempt} is not an english word, stupid"]
    end
  else
    [0, "not in the grid"]
  end
end

def english_word?(word)
  response = open("https://wagon-dictionary.herokuapp.com/#{word}")
  json = JSON.parse(response.read)
  return json['found']
end


end
