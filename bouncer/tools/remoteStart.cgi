#!/usr/bin/ruby -w

require "cgi"

cgi = CGI.new("html4")

start = `/Users/dave/work/ddribin/bouncer/build/Debug/bouncerStart`

cgi.out() do
  cgi.html() do
    cgi.head{ cgi.title{"Remote Start"} } +
    '<meta name="viewport" content="width = 320" />' +
    '<meta name="viewport" content="initial-scale=2.3, user-scalable=no" />' +
    cgi.body() do
      cgi.p{ "Remote Start" } +
      cgi.pre { "#{start}" }
    end
  end
end
