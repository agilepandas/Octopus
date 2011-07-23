module Octopus
  class Wrapper
    attr_accessor :base
    def initialize(base)
      self.base = base
      self.base.logger.info("Starting HTTP backend")
      @mutex = Mutex.new
      @message = {}
      Octopus::Sinatra.owner = self
      Octopus::Sinatra.username = base.config["authentication"]["username"] || "octopus"
      Octopus::Sinatra.password = base.config["authentication"]["password"] || "thebot"
    end

    def message= msg
      @mutex.synchronize do
        @message = msg
      end
    end
  
    def message
      @message
    end

    def run!
      self.base.threads << Thread.new do
        sleep 5
        Octopus::Sinatra.run!
      end
    end
  end
end