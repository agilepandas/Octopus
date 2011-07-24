module Octopus
  class NoConfigFileError < StandardError;end
  class NoPluginError < StandardError;end

  class Base
   attr_accessor :env, :threads, :logger, :config, :http, :should_run, :plugins
   
   # Reads the config file according to the current environment
    def load_config!
      config_file = File.join(File.dirname(__FILE__), "..", "config", "#{self.env}.yml")
      if File.exists?(config_file)
        config = YAML::load(File.open(config_file))
      else
        raise Octopus::NoConfigFileError, "No config found for environment: #{env} tried loading: #{config_file}"
      end
      self.logger.debug("Config-file: #{config.inspect}")
      self.config = config["octopus"]
      
      self.plugins = PluginManager.new self.config["plugins"], self.logger
    end
  
    # Accepts one argument, the environment the bot should be run in.
    def initialize(env = :development)
      Thread.abort_on_exception = true
      self.logger = Logger.new('logfile.log')
      self.env = env
      self.should_run = true
      self.threads = []
      self.load_config!
      self.logger.info("Ocotopus initing!")
    end
    
    # This starts the sinatra backend
    def start_http_backend
      self.http = Octopus::Wrapper.new(self)
      self.http.run!
    end
    
    # Loop over all plugins which are found in the yaml file.
    # It requires them and initiates an object.
    def load_plugins
      self.plugins.all do |plugin|
        # Create new thread for each plugin found in config.
        self.threads << Thread.new do
          logger.info("Loading plugin: #{plugin}")
          begin
            file_name = File.join(File.dirname(__FILE__), "plugins", "#{plugin}.rb")
            logger.debug("Requiring plugin file located at: #{file_name}")
          
            # Require plugin base.
            require file_name
          
            # Acquire class name
            klass = "Octopus::#{plugin.classify}".constantize
            # Instantiate new class
            plugin = klass.new(self)
            # Run the plugin
            plugin.run!
          rescue LoadError
            raise Octopus::NoPluginError, "Plugin not found"
          rescue StandardError => e
            logger.info("Error while loading plugin: #{plugin}")
            logger.debug(e)              
          end
        end
      end
    end
    
    # Makes sure all threads get closed down properly
    def clean_up_threads
       logger.info("Sigint received, closing down")
       self.threads.each {|t| t.terminate}
    end

    def guard!
      self.threads << Thread.new do
        while self.should_run
          sleep 1
          Signal.trap("SIGINT") do
            # Stop main loop
            self.should_run = false
            # Clean up threads
            clean_up_threads
          end
        end
      end
    end
     
    # Method to get everything started yo!
    def run!
      # Register traps and setup watcher thread.
      guard!
      
      self.start_http_backend
      self.load_plugins
      
      self.logger.debug("Threads running: #{self.threads.count}")
      
      if env == :test
        puts "Not joining threads"
      else
        threads.each(&:join)
      end
    end
  end
end