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

  def get_movies_for_actor
    actor = random_ranked_actor
    movie_counts_without_actor = get_movies_of_people_associated_with_a_randomly_ranked_actor(actor)
    top_genrek
    #get_top_genres_of_actors_top_movies(actor)
  end

  def get_movies_of_people_associated_with_a_randomly_ranked_actor(actor)
    movies_id = Redis.current.zrange("actorMovies:#{actor}", 0, 10)
    
    #goes through all the movies a actor has been in and spits out the cast members
    overall_movies = []
    Array(movies_id).each do |movie_id|
      movie = Movie.new(movie_id)
      
      Array(movie.directors).each do |director|
        overall_movies << Redis.current.zrange("directorMovies:#{director}", 0, -1)
      end

      Array(movie.cast).each do |cast_member|
        next if cast_member == actor
        overall_movies << Redis.current.zrange("actorMovies:#{cast_member}", 0, -1)
      end

      Array(movie.writers).each do |writer|
        overall_movies << Redis.current.zrange("writerMovies:#{writer}", 0, -1)
      end
    end

    movie_count = Hash.new(0)
    overall_movies.flatten.each {|movie| movie_count[movie] += 1}
    movie_count
  end

  def get_top_genres_of_actors_top_movies(actor)
    genres = []
    movies = Redis.current.zrange("actorMovies:#{actor}", 0, -1)
    movies.each do |movie|
      genres << Movie.new(movie).genres
    end
    
    genre_count = Hash.new(0)
    genres.flatten.each {|genre| genre_count[genre] += 1}
    genre_count
  end

  #Dan Akroyd -> Has 10 movies -> Each has 10 ppl (! Dan Akroyd) -> Each has 10 Movies
  #
  #1000 movies for each lottery ticket
  #
  #movieCountAll = number of times the candidate movie was linked to in our walker
  #
  #genreCount = Of Dan Akroyd's top 10 movies (by imdbRating), what were the genres?
  #
  #
  #Do below for each "lottery ticket", then sum up score for each movie between lottery tickets
  #
  #score = movieCountAll + (imdbScore * 3) + genreCountOriginalEntity
  # genre count for each of bill murrays movies

  # have a count of the movies that cast members as associated with, have a 
end

