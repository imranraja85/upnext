class Api::UsersController < ApplicationController
  def getnext
    p current_user
    p "*" * 50
    begin
    movie = Movie.new(UserRankings.new(params[:user]).get_recommended_movie)
    rescue
    movie = Movie.new(Redis.current.zrevrange("keys:imdb:byVotes", 0, 200).sample)
    end
    render :json => movie
  end

  #  movie_id: integer
  #  vote: integer
  def sendvote
    UserVote.new(current_user, params[:movie_id], params[:vote]).store
    movie = Movie.new(UserRankings.new(current_user).get_recommended_movie)

    render :json => movie
  end

  def dump
    render :json => UserRankings.new(current_user).all
  end
end
