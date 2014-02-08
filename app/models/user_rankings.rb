class UserRankings
  attr_accessor :user
  def initialize(user)
    @user = user
  end

  def movies_voted_on
    Redis.current.zrange("votes:userMovies:#{user.id}", 0, -1, {with_scores: true})
  end

  def genres
    Redis.current.zrange("votes:userGenres:#{user.id}", 0, -1, {width_scores: true})
  end

  def actors
    Redis.current.zrange("votes:userPeople:#{user.id}:actors", 0, -1, {width_scores: true})
  end

  def writers
    Redis.current.zrange("votes:userPeople:#{user.id}:writers", 0, -1, {width_scores: true})
  end

  def directors
    Redis.current.zrange("votes:userPeople:#{user.id}:directors", 0, -1, {width_scores: true})
  end
end
