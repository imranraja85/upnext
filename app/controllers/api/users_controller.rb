class Api::UsersController < ApplicationController

  #when a user upvotes/downvotes/skips a movie, we call this method
  # expect to receive:
  #   userId
  #   roomId
  #   movieId
  #   vote (positive/netural/negative)
  
  def vote
    #UserVote.vote(params)
    #UserPreference.next_movie
    logger.info params
  end
end
