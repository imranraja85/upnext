class UserRankings
  attr_accessor :user, :room

  def initialize(user, room = nil)
    @user = user
    @room = room
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
    Redis.current.zrange("votes:userMovies:#{user}", 0, -1, {with_scores: true}).reverse
  end

  def genres
    Redis.current.zrange("votes:userGenres:#{user}", 0, -1, {with_scores: true}).reverse
  end

  def actors
    Redis.current.zrange("votes:userPeople:#{user}:actors", 0, -1, {with_scores: true}).reverse
  end

  def writers
    Redis.current.zrange("votes:userPeople:#{user}:writers", 0, -1, {with_scores: true}).reverse
  end

  def directors
    Redis.current.zrange("votes:userPeople:#{user}:directors", 0, -1, {with_scores: true}).reverse
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
      
      ranked << [name] * value.to_i.abs
    end

    ranked.flatten.sample.sub("-", "").sub(".","").sub(",", "").sub("_", "").sub("'","")
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
  def random_movie_with_costar(actor)
    movies_with_actor = Redis.current.zrange("actorMovies:#{actor}", 0, -1)
    movie = Movie.new(movies_with_actor.sample)
    costar = [movie.cast - [actor]].flatten.sample

    movies_with_costar = Redis.current.zrange("actorMovies:#{costar}", 0, -1)
    movies_with_costar.sample
  end

  def random_costar(actor)
    begin 
      movies_with_actor = Redis.current.zrange("actorMovies:#{actor}", 0, -1)
    end while movies_with_actor.nil?

    movie = Movie.new(movies_with_actor.sample)
    [movie.cast - [actor]].flatten.sample.sub("-", "").sub(".","").sub(",", "").sub("_", "").sub("'","")
  end

  def get_recommended_movie
    #p "*" * 50
    #p Redis.current.smembers("rooms:#{room}")
    #users_in_this_room = Redis.current.smembers("rooms:#{room}")
    #if users_in_this_room > 1
    #  users_in_this_room.each do |user|
    #    UserRankings.new("user").genrej
    #  end
    #end

    begin
      actor = random_costar(random_ranked_actor)
      movie_counts_without_actor = get_movies_of_people_associated_with_a_randomly_ranked_actor(actor)
    end while movie_counts_without_actor.nil?

    highest_score = 0
    highest_movie_id = 0

    movie_counts_without_actor.each do |movie, count|
      movie_detail = Movie.new(movie)
      next if Redis.current.zrank("votes:userMovies:#{user}", movie) #user has already watched this movie
      score = count.to_f + movie_detail.rating.to_f + score_genres_in_common_with_actor(actor, movie_detail).to_f
      if score > highest_score
        higest_score = score
        highest_movie_id = movie
      end
    end
    
    binding.pry if highest_movie_id == 0
    highest_movie_id
  end

  def get_movies_of_people_associated_with_a_randomly_ranked_actor(actor)
    movies_id = Redis.current.zrange("actorMovies:#{actor}", 0, 10)
    
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

  def score_genres_in_common_with_actor(actor, movie)
    genre_count = get_top_genres_of_actors_top_movies(actor)
    score = 0
    genre_count.each do |genre, count|
      if Array(movie.genres).include?(genre)
        score = score + count.to_f
      end
    end

    score
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


#only include genres that intersect

