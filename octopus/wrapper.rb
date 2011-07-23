module Octopus
  class Wrapper
    attr_accessor :base
    def initialize(base)
      self.base = base
      
      @mutex = Mutex.new
      @message = {}
      Octopus::Sinatra.owner = self
      # Octopus::Sinatra.username = options["username"] || "octopus"
      # Octopus::Sinatra.password = options["password"] || "thebot"
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