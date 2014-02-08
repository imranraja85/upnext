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

  def movies_by_favorite_actor
  end
end

/*

Look at the top x genres
Look at the top x actors
Look at the top x directors
Look at the top x writers

Genres
-----
Action: 100
Drama: 15
Romance: 1
[A * 100, D * 15, R * 1].sample => your genre

Actors
-----
Bill Murray: 100
Chuck Norris: 10
[B * 100, C * 10].sample => your genre

*/
