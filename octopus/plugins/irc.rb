module Octopus
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
      channel = http.message[:channel]
      if message
        self.debug("Sending: #{http.message}")
        puts channel
        if channel
          channel = self.bot.channels.find{|x| x == "##{channel}"}
        end
        channel ||= self.bot.channels.first
        channel.safe_send(message)
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