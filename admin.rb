require 'sinatra'
require 'json'

get "/lpconfig" do 

  content_type :json
  
  current_map = REDIS.hgetall PROXYMAP_KEY
  current_map.to_json

end

post "/lpconfig" do

  REDIS.hset PROXYMAP_KEY, params[:host], params[:dest]

  redirect_to "/lpconfig"

end

delete "/lpconfig" do 

  REDIS.hdel PROXYMAP_KEY, params[:host]

  redirect_to "/lpconfig"

end