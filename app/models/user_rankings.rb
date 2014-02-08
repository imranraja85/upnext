class UserRankings
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def all
    {
      :movies    => movies,
      :genres    => genres,
      :actors    => actors,
      :directors => directors,
      :writers   => writers
    }
  end

  def movies
    Redis.current.zrange("votes:userMovies:#{user.id}", 0, -1, {with_scores: true}).reverse
  end

  def genres
    Redis.current.zrange("votes:userGenres:#{user.id}", 0, -1, {with_scores: true}).reverse
  end

  def actors
    Redis.current.zrange("votes:userPeople:#{user.id}:actors", 0, -1, {with_scores: true}).reverse
  end

  def writers
    Redis.current.zrange("votes:userPeople:#{user.id}:writers", 0, -1, {with_scores: true}).reverse
  end

  def directors
    Redis.current.zrange("votes:userPeople:#{user.id}:directors", 0, -1, {with_scores: true}).reverse
  end

  
  ##########################
  #
  #  FAVORITE VECTORS
  #
  ##########################
  def favorite_genre
    genres.flatten.first
  end

  def favorite_actor
    actors.flatten.first
  end

  def favorite_writer
    writers.flatten.first
  end

  def favorite_director
    directors.flatten.first
  end


  ###################################
  #
  #  MOVIES BY EACH FAVORITE VECTOR
  #
  ##################################
  def movies_by_favorite_actor
    Redis.current.zrange("actorMovies:#{favorite_actor}", 0, -1)
  end

  def movies_by_favorite_director
    Redis.current.zrange("directorMovies:#{favorite_director}", 0, -1)
  end

  def movies_by_favorite_genre
    Redis.current.zrange("genreMovies:#{favorite_genre}", 0, -1)
  end

  def all_movies_by_top_favorites
    [movies_by_favorite_actor, movies_by_favorite_director, movies_by_favorite_genre].flatten.uniq
  end

  #######################
  #  WEIGHT EACH ONE BY THE TOTAL RANKING
  #######################
  def random_ranked_actor
    ranked = []
    Array(actors).each do |actor|
      name = actor[0] 
      value = actor[1]
      
      ranked << [name] * value.to_i
    end

    ranked.flatten.sample
  end

  def random_ranked_director
    ranked = []
    Array(directors).each do |director|
      name = director[0] 
      value = director[1]
      
      ranked << [name] * value.to_i
    end

    ranked.flatten.sample
  end

  def random_ranked_genre
    ranked = []
    Array(genres).each do |genre|
      name = genre[0] 
      value = genre[1]
      
      ranked << [name] * value.to_i
    end

    ranked.flatten.sample
  end

  #######################################
  #  WEIGHTED WITH CO-ACTOR
  ######################################
  def random_movie_with_costar
    actor = random_ranked_actor
    movies_with_actor = Redis.current.zrange("actorMovies:#{actor}", 0, -1)
    movie = Movie.new(movies_with_actor.sample)
    costar = [movie.cast - [actor]].flatten.sample

    p "top actor: #{actor}"
    p "worked with: #{costar}"

    movies_with_costar = Redis.current.zrange("actorMovies:#{costar}", 0, -1)
    movies_with_costar.sample
  end
end
