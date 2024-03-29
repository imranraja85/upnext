class Api::UsersController < ApplicationController
  def userJoined
    Redis.current.sadd("rooms:#{params[:room]}", params[:user])

    Pusher[params[:room]].trigger('growl', {
      :message => "A new user has joined!",
      :user_id => params[:user]
    })

    Redis.current.incr("Pusher:TotalUserJoined")
    Redis.current.incr("Pusher:TotalMessages")

    render :json => {:success => true}
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
    voted_on_movie = Movie.new(params[:movie_id])
    begin
      @movie = Movie.new(UserRankings.new(params[:user], params[:room]).get_recommended_movie)
    rescue
      @movie = Movie.new(Redis.current.zrevrange("keys:imdb:byVotes", 0, 200).sample)
    end

    if ["1", "-1"].include?(params[:vote])
      Pusher[params[:room]].trigger('growl', {
        :message => "Someone #{map_vote(params["vote"])} #{voted_on_movie.title}!",
        :user_id => params[:user]
      })
     Redis.current.incr("Pusher:TotalVotes")
     Redis.current.incr("Pusher:TotalMessages")
    end

  end

  def addVideo
    movie = Movie.new(params[:movie_id])

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

  def postMessage
    Pusher[params[:room]].trigger('growl', {
      message: params[:message],
      user_id: params[:user]
    })
    Redis.current.incr("Pusher:ChatMessages")
    Redis.current.incr("Pusher:TotalMessages")

    render :json => {:success => true}
  end

  def dump
    render :json => UserRankings.new(current_user).all
  end

  def messageCounts
    resp = {:total_messages      => Redis.current.get("Pusher:TotalMessages"),
            :total_user_joined   => Redis.current.get("Pusher:TotalUserJoined"),
            :total_chat_messages => Redis.current.get("Pusher:ChatMessages"),
            :total_votes         => Redis.current.get("Pusher:TotalVotes"),
            :total_positive      => Redis.current.get("Pusher:TotalUpvotes"),
            :total_negative      => Redis.current.get("Pusher:TotalDownvotes")}     

    render :json => resp
  end

  private
  def map_vote(vote)
    if vote == '1' 
       Redis.current.incr("Pusher:TotalUpvotes")
      "upvoted"
    elsif vote == '-1'
       Redis.current.incr("Pusher:TotalDownvotes")
      "downvoted"
    end
  end
end
