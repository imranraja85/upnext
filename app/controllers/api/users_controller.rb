class Api::UsersController < ApplicationController
  # data: {
  #  user: "123",
  #  room: "345"
  # }
  def getnext
  end

  #expects two parameters:
  # movie_id: integer
  # vote: integer
  def sendvote
    UserVote.new(current_user, params[:movie_id], params[:vote]).store
  
    #UserPreference.next_movie
    logger.info params
  end
end
