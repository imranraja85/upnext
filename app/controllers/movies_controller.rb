class MoviesController < ApplicationController
  def index
    @top_10_movies = REDIS.zrevrange("keys:imdb:byRating", 0, 10)
  end
end
