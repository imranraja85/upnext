#only set msg if we have no data
#json.set :msg do
#end

json.response do
  json.docs do
    json.set! :id, @movie.id
    json.set! :name, @movie.title
    json.set! :Year, @movie.year
    json.set! :imdbRating, @movie.rating
    json.set! :hi, "HI"
  end
end
