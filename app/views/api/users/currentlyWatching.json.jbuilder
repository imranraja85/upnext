if @movie.id.nil?
  json.success false 
else
  json.response do
    json.docs do
      json.set! :id, @movie.id
      json.set! :name, @movie.title
      json.set! :Year, @movie.year
      json.set! :imdbRating, @movie.rating
    end
  end
end
