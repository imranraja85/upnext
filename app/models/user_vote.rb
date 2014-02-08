class UserVote
  attr_accessor :user, :movie_id, :vote, :redis, :movie

  def initialize(user, movie_id, vote)
    @user       = user
    @movie_id   = 117665
    @vote       = vote #this needs to be a numerical value
    @movie      = Movie.new(@movie_id)
  end

  def store
    store_movie
    store_genre
    store_cast
    store_directors
    store_writers
  end

  def store_movie
    Redis.current.zincrby("votes:userMovies:#{user.id}", vote, movie_id)
  end

  def store_genre
    Array(movie.genres).each do |genre|
      Redis.current.zincrby("votes:userGenres:#{user.id}", vote, genre)
    end
  end

  def store_cast
    Array(movie.cast).each do |cast_member|
      Redis.current.zincrby("votes:userPeople:#{user.id}:actors", vote, cast_member)
    end
  end

  def store_writers
    Array(movie.writers).each do |writer|
      Redis.current.zincrby("votes:userPeople:#{user.id}:writers", vote, writer)
    end
  end

  def store_directors
    Array(movie.directors).each do |director|
      Redis.current.zincrby("votes:userPeople:#{user.id}:directors", vote, director)
    end
  end
end
