class MovieRecommendation
  attr_accessor :user, :user_rankings

  def initialize(user)
    @user_rankings = UserRankings.new(user)
  end

  def recommend
    movie_rankings = user_rankings.movies 
    genre_rankings = user_rankings.genres
    actor_rankings = user_rankings.actors
    writer_rankings = user_rankings.writers
    director_rankings = user_rankings.directors

    {
      :movies_voted      => movie_rankings,
      :genre_rankings    => actor_rankings,
      :actor_rankings    => actor_rankings,
      :writer_rankings   => writer_rankings,
      :director_rankings => director_rankings
    }
  end

end
