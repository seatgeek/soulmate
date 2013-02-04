Soulmate
========

Soulmate is a tool to help solve the common problem of developing a fast autocomplete feature. It uses Redis's sorted sets to build an index of partially completed words and the corresponding top matching items, and provides a simple sinatra app to query them. Soulmate finishes your sentences.

Soulmate was designed to be simple and fast, and offers the following:

 * Provide suggestions for multiple types of items in a single query (at SeatGeek we're autocompleting for performers, events, and venues)
 * Results are ordered by a user-specified score
 * Arbitrary metadata for each item (at SeatGeek we're storing both a url and a subtitle)

An item is a simple JSON object that looks like:

    {
      "id": 3,
      "term": "Citi Field",
      "score": 81,
      "data": {
        "url": "/citi-field-tickets/",
        "subtitle": "Flushing, NY"
      }
    }

Where `id` is a unique identifier (within the specific type), `term` is the phrase you wish to provide completions for, `score` is a user-specified ranking metric (redis will order things lexicographically for items with the same score), and `data` is an optional container for metadata you'd like to return when this item is matched (at SeatGeek we're including a url for the item as well as a subtitle for when we present it in an autocomplete dropdown).

See Soulmate in action at <a href="http://seatgeek.com/">SeatGeek</a>.

Getting Started
---------------

As always, kick things off with a `gem install`:

    gem install soulmate

### Loading Items

You can load data into Soulmate by piping items in the JSON lines format into `soulmate load TYPE`.

Here's a sample `venues.json` (one JSON item per line):

    {"id":1,"term":"Dodger Stadium","score":85,"data":{"url":"\/dodger-stadium-tickets\/","subtitle":"Los Angeles, CA"}}
    {"id":28,"term":"Angel Stadium","score":85,"data":{"url":"\/angel-stadium-tickets\/","subtitle":"Anaheim, CA"}}
    {"id":30,"term":"Chase Field ","score":85,"data":{"url":"\/chase-field-tickets\/","subtitle":"Phoenix, AZ"}}
    {"id":29,"term":"Sun Life Stadium","score":84,"data":{"url":"\/sun-life-stadium-tickets\/","subtitle":"Miami, FL"}}
    {"id":2,"term":"Turner Field","score":83,"data":{"url":"\/turner-field-tickets\/","subtitle":"Atlanta, GA"}}

And here's the load command (Soulmate assumes redis is running locally on the default port, or you can specify a redis connection string with the `--redis` argument):

    $ soulmate load venue --redis=redis://localhost:6379/0 < venues.json

You can also provide an array of strings under the `aliases` key that will also be added to the index for this item.

### Querying for Data

Once it's loaded, we can query this data by starting `soulmate-web`:

    $ soulmate-web --foreground --no-launch --redis=redis://localhost:6379/0

And viewing the service in your browser: http://localhost:5678/search?types[]=venue&term=stad. You should see something like:

    {
      "term": "stad",
      "results": {
        "venue": [
          {
            "id": 28,
            "term": "Angel Stadium",
            "score": 85,
            "data": {
              "url": "/angel-stadium-tickets/",
              "subtitle": "Anaheim, CA"
            }
          },
          {
            "id": 1,
            "term": "Dodger Stadium",
            "score": 85,
            "data": {
              "url": "/dodger-stadium-tickets/",
              "subtitle": "Los Angeles, CA"
            }
          },
          {
            "id": 29,
            "term": "Sun Life Stadium",
            "score": 84,
            "data": {
              "url": "/sun-life-stadium-tickets/",
              "subtitle": "Miami, FL"
            }
          }
        ]
      }
    }

The `/search` method supports multiple `types` as well as an optional `limit`. For example: `http://localhost:5678/search?types[]=event&types[]=venue&types[]=performer&limit=3&term=yank`. You can also add the `callback` parameter to enable JSONP output.

### Mounting soulmate into a rails app

If you are integrating Soulmate into a rails app, an alternative to launching a separate 'soulmate-web' server is to mount the sinatra app inside of rails.

Add this to routes.rb:

    mount Soulmate::Server, :at => "/sm"

Add this to gemfile:

    gem 'rack-contrib'
    gem 'soulmate', :require => 'soulmate/server'

Then you can query soulmate at the /sm url, for example: http://localhost:3000/sm/search?types[]=venues&limit=6&term=kitten

You can also config your redis instance:

    # config/initializers/soulmate.rb
    
    Soulmate.redis = 'redis://127.0.0.1:6379/0'
    # or you can asign an existing instance of Redis, Redis::Namespace, etc.
    # Soulmate.redis = $redis

### Rendering an autocompleter

Soulmate doesn't include any client-side code necessary to render an autocompleter, but Mitch Crowe put together a pretty cool looking jquery plugin designed for exactly that: <a href="https://github.com/mcrowe/soulmate.js">soulmate.js</a>.

Contributing to soulmate
------------------------
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2011 Eric Waller. See LICENSE.txt for further details.

