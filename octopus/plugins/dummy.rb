module Octopus
  # Dummy plugin used as basic example and for test-cases
  # This should probably be moved elsewhere
  class Dummy < Octopus::Plugin
    def name
      "dummy"
    end
      
    def initialize(base)
      super
      self.info("Loading dummy plugin")
    end
    
    def run!
      while self.base.should_run
        self.debug("Checking for message")
        if http.message && http.message[:plugin] == self.name
          self.info("Message from dummy plugin")
          http.message = nil
        end
        sleep 1
      end
      exit
    end
  end
end