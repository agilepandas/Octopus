require 'spec_loader'

describe Octopus::Base do
  octopus = Octopus::Base.new
  
  context "A new octopus base object" do 
    it "should have logging setup" do
      octopus.logger.class.should be(Logger)
    end
    
    it "should run in development if no envirnoment is given" do
      octopus.env == :development
    end
    
    it "should run in the specified environment if given" do
      octopus = Octopus::Base.new(:production)
      octopus.env == :production
    end
    
    it "should load the associated config file" do
      octopus = Octopus::Base.new(:test)
      octopus.config["authentication"]["username"].should == "test"
      octopus.config["authentication"]["password"].should == "test"
    end
    
    it "should throw an error if the config file could not be read" do
      lambda {octopus = Octopus::Base.new(:idontexist)}.should raise_error(Octopus::NoConfigFileError)
    end
  end
  
  context "A octopus base object ready to be run" do
    it "should start the http wrapper thread" do 
      octopus = Octopus::Base.new(:test)
      octopus.start_http_backend
      octopus.threads.count.should be(1)
    end
    
    it "should load any plugins that are specified" do
      octopus = Octopus::Base.new(:test)
      octopus.run!
      octopus.threads.count.should be(3)
    end
  end
end
