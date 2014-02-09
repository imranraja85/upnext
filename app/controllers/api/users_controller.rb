class Api::UsersController < ApplicationController
  def getnext
    Redis.current.sadd("rooms:#{params[:room]}", params[:user])

    begin
      @movie = Movie.new(UserRankings.new(params[:user], params[:room]).get_recommended_movie)
    rescue
      @movie = Movie.new(Redis.current.zrevrange("keys:imdb:byVotes", 0, 200).sample)
    end

    Pusher['test_channel'].trigger('user_clicked_next', {
      message: "#{params[:user]} has clicked next"
    })
  end

  def sendvote
    Redis.current.sadd("rooms:#{params[:room]}", params[:user])

    UserVote.new(current_user, params[:movie_id], params[:vote]).store
    begin
      @movie = Movie.new(UserRankings.new(params[:user]).get_recommended_movie)
    rescue
      @movie = Movie.new(Redis.current.zrevrange("keys:imdb:byVotes", 0, 200).sample)
    end

    Pusher['test_channel'].trigger('user_voted', {
      message: "#{params[:user]} has voted: #{params[:vote]}",
      user: params[:user],
      vote: params[:vote]
    })
  end

  def addVideo
    movie = Movie.new(params[:movie_id])
    Pusher['test_channel'].trigger('user_added_video', {
      message: "#{params[:user]} added the trailer #{movie.title}",
      user: params[:user],
      movie: movie.title
    })

    render :json => {:success => true}
  end

  def dump
    render :json => UserRankings.new(current_user).all
  end
end
