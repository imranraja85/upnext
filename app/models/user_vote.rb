class UserVote
  attr_accessor :user, :movie_id, :vote, :redis, :movie

  def initialize(user, movie_id, vote)
    @user       = user
    @movie_id   = 117665
    @vote       = vote
    @movie      = Movie.new(@movie_id)
  end

  def store
    store_movie
    store_genre
    store_people
  end

  def store_movie
    Redis.current.zadd("userMovies:#{user.id}", 1 ,"#{movie_id}")
  end

  def store_genre
     Redis.current.zadd("userGenres:#{user.id}", 1 ,"#{figureouthtemoviegenre}")
  end

  def store_people
    Redis.current.zadd("userPeople:#{user.id}", 1 ,"#{figureoutactorids}")
    Redis.current.zadd("userPeople:#{user.id}", 1 ,"#{figureoutwriterids}")
    Redis.current.zadd("userPeople:#{user.id}", 1 ,"#{figureoutdirectorids}")
  end

end


