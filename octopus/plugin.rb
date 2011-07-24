module Octopus
  class PluginManager
    attr_accessor :config, :logger
    def initialize config, logger
      self.config = config
      self.logger = logger
    end
    
    def all
      if config.is_a? Array
        logger.info("#{config.count} plugins found")
        
        config.each do |plugin|
          logger.info("Initializing plugin: #{plugin}")
          # Yield each plugin
          yield plugin
        end
      else
        logger.info("No plugins found")
      end
    end
  end
end