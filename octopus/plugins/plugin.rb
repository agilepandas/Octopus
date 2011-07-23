module Octopus
  class Plugin

    # Name of the plugin, used for logging and matching messages
    def name
      "plugin"
    end
    
    attr_accessor :logger, :config, :http, :base

    # Small wrapper to add in some basic information such as which plugin is spamming the logs
    def debug(message)
      self.logger.debug(self.name + ": " + message)
    end
    
    def info(message)
      self.logger.info(self.name + ": " + message)
    end
    
    # All plugins should get the Octopus::Base instance as argument
    def initialize(base, options = {})
      self.parse_options(base.config)
      self.logger = base.logger
      self.http = base.http
      self.base = base
    end
    
    # The parse method will be called upon when there is a matching message send to this plugin
    # It will do the actual magic for this plugin
    def parse(http)
      debug(http.message.inspect)
    end
    
    # The method that will be run when the plugin is initialized
    # This should be considered the main loop
    # If a message send over HTTP is present and the plugin matches the current plugin the message
    # will be passed to the parse method
    def run!
      self.debug("is running")
      while self.base.should_run 
        self.debug("Checking for message")

        if http.message && http.message[:plugin] == self.name
          parse(http)
        end
        sleep 3
      end
      exit
    end

    # method that read the global config file and setups up the local plugin config file
    def parse_options(config)
      if config.has_key?(self.name)
        self.config = config[self.name]
      end
    end
  end
end