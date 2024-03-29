class Movie
  attr_accessor :redis, :title, :genres, :cast, :writers, :directors, :poster, :year, :rating, :id

  def initialize(movie_id)
    movie_hash = Redis.current.hmget("imdb:#{movie_id}", "Title", "Genre", "Cast", "Writer", "Director", "Year", "Poster", "imdbRating", "ID")
    @title      = movie_hash[0] 
    @genres     = movie_hash[1]
    @cast       = movie_hash[2]
    @writers    = movie_hash[3]
    @directors  = movie_hash[4]
    @year       = movie_hash[5]
    @poster     = movie_hash[6]
    @rating     = movie_hash[7]
    @id         = movie_hash[8]
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

#get the genres of the current movie. get the current of the actor actor. if the genres align, sum up the actors genre count
