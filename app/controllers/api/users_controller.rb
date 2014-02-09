class Api::UsersController < ApplicationController
  # data: {
  #  user: "123",
  #  room: "345"
  # }
  def getnext
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
