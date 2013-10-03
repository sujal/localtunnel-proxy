require 'sinatra'
require 'json'

LP_SECRET=ENV["LP_SECRET"]

get "/lpconfig" do 

  raise Sinatra::NotFound unless params[:secret] == LP_SECRET

  content_type :json
  
  current_map = REDIS.hgetall PROXYMAP_KEY
  current_map[:default] = ENV["LP_DEFAULT_URL"]
  current_map.to_json

end

post "/lpconfig" do

  raise Sinatra::NotFound unless params[:secret] == LP_SECRET

  REDIS.hset PROXYMAP_KEY, params[:host], params[:dest]

  redirect to("/lpconfig?secret=#{params[:secret]}")

end

delete "/lpconfig" do 

  raise Sinatra::NotFound unless params[:secret] == LP_SECRET

  REDIS.hdel PROXYMAP_KEY, params[:host]

  redirect to("/lpconfig?secret=#{params[:secret]}")

end

not_found do
  "Not Found"
end