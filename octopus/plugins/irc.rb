module Octopus
  # Octopus plugin class that spawns a irc bot that sits in the supplied channels and relays messages.
  # The target is a IRC-room to talk in.
  # ie.
  # /say/irc/agile-pandas/Hello
  class Irc < Octopus::Plugin
    attr_accessor :bot

    def name
      "irc"
    end

    def initialize(base, options = {})
      super
      
      if self.config.empty?
        self.info("Error while loading config")
      else
        self.info("Booting")
      end
      
      config = self.config
      self.debug("config: #{config.inspect}")
      bot = Cinch::Bot.new do
        configure do |c|
          c.server = config["server"]
          c.channels = config["channels"]
          c.nick = config["nick"]
          c.realname = config["real_name"]
        end
      end

      self.bot = bot
    end
  
    def parse(http)
      message = http.message[:message]
      target = http.message[:target]
      if message
        self.debug("Sending: #{http.message} to #{target}")
        if target
          channel = self.bot.channels.find{|x| x == "##{channel}"}
        end
        
        if channel
          channel.safe_send(message)
        else
          self.info("Not in channel, forgetting about the message")
        end
        
        http.message = nil
      end
    end
    
    
    def run!
      self.base.threads << Thread.new do
        self.bot.start
      end

      super
    end
  end
end