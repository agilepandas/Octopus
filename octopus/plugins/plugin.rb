module Octopus
  class Plugin
    def name
      "plugin"
    end
    
    attr_accessor :logger, :config, :http, :base

    def debug(message)
      self.logger.debug(self.name + ": " + message)
    end
    
    def info(message)
      self.logger.info(self.name + ": " + message)
    end
    
    def initialize(base, options = {})
      self.parse_options(base.config)
      self.logger = base.logger
      self.http = base.http
      self.base = base
    end
    
    def parse(http)
      debug(http.message.inspect)
    end
    
    def run!
      self.debug("Bot is running!")
      while self.base.should_run 
        self.debug("Checking for message")

        if http.message && http.message[:plugin] == self.name
          parse(http)
        end
        sleep 3
      end
      exit
    end

    def parse_options(config)
      if config.has_key?(self.name)
        self.config = config[self.name]
      end
    end
  end
end