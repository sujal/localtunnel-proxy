# localtunnel-proxy

## About

A simple reverse proxy that I needed to forward requests to a SSH tunnel using the [localtunnel gem](http://progrium.com/localtunnel/).

Install this app on Heroku, so you have a stable endpoint, then point things to that (Heroku) URL. (Maybe these things are app configurations, OAuth callbacks, stable URLs to show others your work).

## Usage

You need to configure 3 environment variables in order to use this:

````
LP_DEFAULT_URL=http://somewhere.dev/
REDIS_URL=redis://localhost:6379/
LP_SECRET=something

````

The `LP_SECRET` and `REDIS_URL` are optional. Use them if you want to enable custom mappings for different hosts. For example, I use a single Heroku app instance for our app with multiple subdomains configured in Heroku for this. That way, I can do something like map: 

````
dev1.example.com => abcd.localtunnel.com
dev2.example.com => efgh.localtunnel.com
````

and so on.

`LP_DEFAULT_URL` should be a URL without the trailing slash that you want all unmapped requests redirected to.

### The Admin Interface

There's one endpoint: `/lpconfig`. Depending on your HTTP Method, you'll list, set, or delete domain mappings:

__GET__: it returns all the mappings it knows about, including the default.

__POST__: send a `host` and `dest` param to map a different forwarding host for a given URL. For our dev1.example.com example above, you'd call the endpoint with a url encoded request body containing these values:

````
host=dev1.example.com
dest=http//abcd.localtunnel.com
secret=something
````

__DELETE__: include a `host` param to delete its mapping.

For all requests, you must pass in a `secret` param either in the POST body or query string. I think Sinatra is picky about this, but I honestly haven't tested it thoroughly (2 hour hack, after all).

The value for `secret` should be whatever you set for the `LP_SECRET` environment variable.

### Miscellany

Instead of `REDIS_URL` you can specify `REDISTOGO_URL` - this is just a shortcut so once I added the RedisToGo Heroku Add-on, I wouldn't need to configure a different variable.

## License

See the LICENSE file. 
