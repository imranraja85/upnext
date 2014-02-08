class Api::UsersController < ApplicationController
  # data: {
  #  user: "123",
  #  room: "345"
  # }
  def getnext
  end

  def sendvote
    #UserVote.vote(params)
    #UserPreference.next_movie
    logger.info params
  end
end
