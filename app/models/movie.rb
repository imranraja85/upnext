class Movie
  attr_accessor :redis, :title, :genres, :cast, :writers, :directors, :poster, :year

  def initialize(movie_id)
    movie_hash = Redis.current.hmget("imdb:#{movie_id}", "Title", "Genre", "Cast", "Writer", "Director", "Year", "Poster")
    @title      = movie_hash[0] 
    @genres     = movie_hash[1]
    @cast       = movie_hash[2]
    @writers    = movie_hash[3]
    @directors  = movie_hash[4]
    @year       = movie_hash[5]
    @poster     = movie_hash[6]
  end

  def genres
    @genres.unpack("C*").pack("U*").split(", ")
  end

  def cast
    @cast.unpack("C*").pack("U*").split(", ").uniq
  end

  def writers
    @writers.unpack("C*").pack("U*").split(", ").uniq
  end
  
  def directors
    @directors.unpack("C*").pack("U*").split(", ").uniq
  end
end
