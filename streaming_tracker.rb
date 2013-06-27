require 'em-http'
require 'em-http/middleware/oauth'
require 'json'

usage = "#{$0} <track>"

abort usage unless keywords = ARGV.shift

OAuthConfig = {
  :consumer_key => '<your consumer key>',
  :consumer_secret => '<your consumer secret>',
  :access_token => '<your access token>',
  :access_token_secret => '<your access token secret>'
}

def track(keywords)
  EventMachine.run do
    conn = EventMachine::HttpRequest.new("https://stream.twitter.com/1.1/statuses/filter.json",
      :connection_timeout => 0,
      :inactivity_timeout => 0)
    
    conn.use EventMachine::Middleware::OAuth, OAuthConfig

    http = conn.post(
      :body => {'track' => keywords},
      :keepalive => true,
      :timeout => -1) 

      buffer = ""
      http.stream do |chunk|
        buffer += chunk
        while line = buffer.slice!(/.+\r?\n/)
          tweet = JSON.parse(line)
          puts Time.new.to_s + "#{tweet['user']['screen_name']}: #{tweet['text']}"
        end

      end

      http.errback {
        puts Time.new.to_s + " Error: "
        puts http.error
      }

  end  
  rescue => ex
    puts "Error " + ex.to_s
end

track keywords