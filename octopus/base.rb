module Octopus
  class NoConfigFileError < StandardError;end
  class NoPluginError < StandardError;end

  class Base
   attr_accessor :env, :threads, :logger, :config, :http, :should_run
   
    def load_config!
      config_file = File.join("#{File.dirname(__FILE__)}/../config/", "#{self.env}.yml")
      if File.exists?(config_file)
        config = YAML::load(File.open(config_file))
      else
        raise Octopus::NoConfigFileError, "No config found for environment: #{env} tried loading: #{config_file}"
      end
      self.logger.debug("Config-file: #{config.inspect}")
      self.threads = []
      self.config = config["octopus"]
    end
  
    def initialize(env = :development)
      Thread.abort_on_exception = true
      self.logger = Logger.new('logfile.log')
      self.env = env
      self.should_run = true
      self.load_config!
      self.logger.info("Ocotopus initing!")
    end
    
    def start_http_backend
      self.http = Octopus::Wrapper.new(self)
      http.run!
    end
    
    def load_plugins
      if self.config["plugins"].class == Array
        logger.info("#{self.config["plugins"].count} plugins found")
        self.config["plugins"].each do |plugin|
          self.threads << Thread.new do
            logger.info("Loading plugin: #{plugin}")
            begin
              file_name = File.dirname(__FILE__) + "/plugins/#{plugin}.rb"
              logger.debug("Requiring plugin file located at: #{file_name}")
              require File.dirname(__FILE__) + "/plugins/#{plugin}.rb"
              klass = "Octopus::#{plugin.classify}".constantize
              instance = klass.new(self)
              instance.run!
            rescue LoadError
              raise Octopus::NoPluginError, "Plugin not found"
            rescue StandardError
              logger.info("Error while loading plugin: #{plugin}")
            end
          end
        end
      else
        logger.info("No plugins found")
      end
    end
    
    def clean_up_threads
       logger.info("Sigint received, closing down")
       self.threads.each {|t| t.terminate}
     end
     
    def run!
      self.threads << Thread.new do
        while self.should_run
          self.logger.debug("Threads running: " + self.threads.count.to_s)
          sleep 1
          Signal.trap("SIGINT") do
            self.should_run = false
          end
          if self.should_run == false
            clean_up_threads
          end
        end
      end
      
      self.start_http_backend
      self.load_plugins
      
      if env == :test
        puts "Not joining threads"
      else
        threads.each(&:join)
      end
    end
  end
end