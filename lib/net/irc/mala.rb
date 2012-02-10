require 'net/irc'
require 'net/irc/cli'
require 'net/irc/mala'
require "em-eventsource"
require 'json'
require "optparse"

class Net::IRC::Mala < Net::IRC::Server::Session
  def initialize(*args)
    super
  end

  def server_name
    "malastream"
  end

  def main_channel
    "#malastream"
  end

  def on_user(m)
    super

    post server_name, MODE, @nick, "+o"
    post @prefix, JOIN, main_channel
    post server_name, MODE, main_channel, "+mto", @nick
    post server_name, MODE, main_channel, "+q", @nick

    @streaming_thread = Thread.start do
      streaming_main
    end
  end

  def on_disconnected
    @streaming_thread.kill rescue nil
  end

  def streaming_main
    EM.run do
      api = "http://api.ma.la/home_timeline/stream"
      source = EventMachine::EventSource.new(api)
      source.message do |message|
        begin
          status = JSON.parse(message)
          tweet = status["text"]
          screen_name = status['user']['screen_name']
          post screen_name, PRIVMSG, main_channel, tweet
        rescue => ex
          STDERR.puts "error: #{ex.inspect}"
          next
        end
      end
      source.start # Start listening
    end
  end
end
