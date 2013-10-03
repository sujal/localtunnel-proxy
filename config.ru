require 'rack/reverse_proxy'
require "redis"

PROXYMAP_KEY = "ltproxmap"

uri = URI.parse(ENV["REDIS_URL"]||ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

use Rack::ReverseProxy do
  reverse_proxy_options :preserve_host => false
  reverse_proxy /^(?!\/lpconfig)/, lambda { |env|

    rackreq = Rack::Request.new(env)
    dest = REDIS.hget(PROXYMAP_KEY, rackreq.host) || REDIS.hget(PROXYMAP_KEY, rackreq.host_with_port)

    if dest.nil?
      dest = ENV["LP_DEFAULT_URL"]
    end

    _url = dest
    path = rackreq.fullpath
    
    # yes, performance stupidity... doesn't matter - this is for development
    temp = URI(_url)

    # we only support HTTP for now...
    env["HTTP_HOST"] = if temp.port != 80
      temp.host
    else
      "#{temp.host}:#{temp.port}"
    end

    if _url =~ /\$\d/
      match_path(path).to_a.each_with_index { |m, i| _url.gsub!("$#{i.to_s}", m) }
      URI(_url)
    else
      URI.join(_url, path)
    end



  }
end


require './admin'
run Sinatra::Application