require 'eventmachine'
require 'em-http'
require 'json'

usage = "#{$0} <user> <password> <track>"
abort usage unless user = ARGV.shift
abort usage unless password = ARGV.shift
abort usage unless keywords = ARGV.shift

def track(user, password, keywords)
  EventMachine.run do
    http = EventMachine::HttpRequest.new("https://stream.twitter.com/1.1/statuses/filter.json").post(
      :head => {'Authorization' => [user, password]}, 
      :body => {'track' => keywords},
      :keepalive => true)

      buffer = ""
      http.stream do |chunk|
        buffer += chunk
        while line = buffer.slice!(/.+\r?\n/)
          tweet = JSON.parse(line)
          puts Time.new.to_s+"#{tweet['user']['screen_name']}: #{tweet['text']}"
        end

      end
  end  
  rescue => ex
    puts "Error " + ex.to_s
end

while true
    track user, password, keywords
end

