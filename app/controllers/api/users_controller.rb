class Api::UsersController < ApplicationController
  def userJoined
    Redis.current.sadd("rooms:#{params[:room]}", params[:user])
    room_user_count = Redis.current.smembers("rooms:#{params[:room]}").count

    Pusher[params[:room]].trigger('user_joined', {
      :count => room_user_count
    })

    render :json => {:count => room_user_count}
  end

  def getnext
    Redis.current.sadd("rooms:#{params[:room]}", params[:user])

    begin
      @movie = Movie.new(UserRankings.new(params[:user], params[:room]).get_recommended_movie)
    rescue
      @movie = Movie.new(Redis.current.zrevrange("keys:imdb:byVotes", 0, 200).sample)
    end

    Pusher[params[:room]].trigger('user_clicked_next', {
      message: "#{params[:user]} has clicked next",
      user: params[:user],
      movie: {:id => @movie.id, :name => @movie.title, :Year => @movie.year, :imdbRating => @movie.rating}
    })
  end

  def sendvote
    Redis.current.sadd("rooms:#{params[:room]}", params[:user])

    UserVote.new(current_user, params[:movie_id], params[:vote]).store
    begin
      @movie = Movie.new(UserRankings.new(params[:user], params[:room]).get_recommended_movie)
    rescue
      @movie = Movie.new(Redis.current.zrevrange("keys:imdb:byVotes", 0, 200).sample)
    end

    Pusher[params[:room]].trigger('user_voted', {
      message: "#{params[:user]} has voted: #{params[:vote]}",
      user: params[:user],
      vote: params[:vote],
      movie: {:id => @movie.id, :name => @movie.title, :Year => @movie.year, :imdbRating => @movie.rating}
    })
  end

  def addVideo
    movie = Movie.new(params[:movie_id])

    Pusher[params[:room]].trigger('user_added_video', {
      message: "#{params[:user]} added the trailer #{movie.title}",
      user: params[:user],
      movie: {:id => @movie.id, :name => @movie.title, :Year => @movie.year, :imdbRating => @movie.rating}
    })

    render :json => {:success => true}
  end

  def currentlyWatching
    movie_id = Redis.current.get("rooms:lastWatched:#{params[:room]}")
    @movie = Movie.new(movie_id)
  end

  def lastWatched
    Redis.current.set("rooms:lastWatched:#{params[:room]}", params[:movie_id])

    render :json => {:movie => true}
  end

  def dump
    render :json => UserRankings.new(current_user).all
  end
end
