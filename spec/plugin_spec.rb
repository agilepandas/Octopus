require 'spec_loader'

describe Octopus::Plugin do
  context "A new plugin" do 
    base = Octopus::Base.new(:test)
    octopus = Octopus::Plugin.new(base)

    it "Should respond with it's name to the name method" do      
      octopus.name.should == "plugin"
    end
    
    it "Should parse it's own config from the config files" do
      octopus.config["test"].should == true
    end
    
    it "Should supply the logger object" do
      octopus.logger.should be(base.logger)
    end
  end
end