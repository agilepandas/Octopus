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

    def parse_options(config)
      if config.has_key?(self.name)
        self.config = config[self.name]
      end
    end
  end
end