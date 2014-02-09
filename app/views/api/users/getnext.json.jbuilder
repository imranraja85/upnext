#only set msg if we have no data
#json.set :msg do
#end

json.response do
  json.docs do
    json.set! :movieId, @movie.id
    json.set! :name, @movie.title
    json.set! :image, @movie.poster
    json.set! :year, @movie.year
    json.set! :rating, @movie.rating
  end
end
