#only set msg if we have no data
#json.set :msg do
#end

json.response do
  json.docs do
    json.set! :action, 'downvote'
    json.set! :user, '999'
    json.set! :movieId, '123'
    json.set! :nextMovie do
      json.set! :movieId, '456'
      json.set! :title, 'The Hunger Games'
      json.set! :image, 'someimage.png'
      json.set! :year, '2013'
      json.set! :rating, '8.1'
      json.set! :youtubeid, '1111'
    end
  end
end
