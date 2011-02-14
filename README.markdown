Soulmate
========

Soulmate is a tool to help solve the common problem of developing a fast autocomplete feature. It uses Redis's sorted sets to build an index of partial words and corresponding top matches, and provides a simple sinatra app to query them. Soulmate finishes your sentences.

Soulmate can offer suggestions for multiple types of items in a single query. An item is a simple JSON object that looks like:

  {
    "id": 3,
    "term": "Citi Field",
    "score": 81,
    "data": {
      "url": "/citi-field-tickets/",
      "subtitle": "Flushing, NY"
    }
  }

Where `id` is a unique identifier (within the specific type), `term` is the phrase you wish to provide completions for, `score` is a user-specified ranking metric (redis will order things lexigraphically for items with the same score), and `data` is an optional container for metadata you'd like to return when this item is matched (at SeatGeek we're including a url for the item as well as a subtitle for when we present it in an autocomplete dropdown).

Getting Started
---------------

You can load data into Soulmate by piping items into `soulmate load`.

Here's a sample `venues.json` (in the JSON lines format -- i.e. one JSON item per line):

  {"id":1,"term":"Dodger Stadium","score":85,"data":{"url":"\/dodger-stadium-tickets\/","subtitle":"Los Angeles, CA"}}
  {"id":28,"term":"Angel Stadium","score":85,"data":{"url":"\/angel-stadium-tickets\/","subtitle":"Anaheim, CA"}}
  {"id":30,"term":"Chase Field ","score":85,"data":{"url":"\/chase-field-tickets\/","subtitle":"Phoenix, AZ"}}
  {"id":29,"term":"Sun Life Stadium","score":84,"data":{"url":"\/sun-life-stadium-tickets\/","subtitle":"Miami, FL"}}
  {"id":2,"term":"Turner Field","score":83,"data":{"url":"\/turner-field-tickets\/","subtitle":"Atlanta, GA"}}

And the load command (with redis running locally on the default port, or specify a redis connection string with the `--redis` argument):

  $ soulmate load venue --redis=redis://localhost:6379/0 < venues.json

Once it's loaded, we can query this data by starting `soulmate-web`:

  $ soulmate-web --foreground --redis=redis://localhost:6379/0 --no-launch

And viewing the service in your browser: <a href="http://localhost:5678/search?types[]=venue&term=stad">http://localhost:5678/search?types[]=venue&term=stad</a>. You should see something like:

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

== Contributing to soulmate
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2011 Eric Waller. See LICENSE.txt for
further details.

