require 'spec_loader'

describe Octopus::Irc do
  context "A new IRC plugin" do 
    base = Octopus::Base.new(:test)
    octopus = Octopus::Irc.new(base)

    it "Should respond with it's name to the name method" do      
      octopus.name.should == "irc"
    end
    
    it "Should parse it's own config from the config files" do
      octopus.config.class.should be(Hash)
      octopus.config["nick"].should == "Octopus"
    end
    
    it "Should supply the logger object" do
      octopus.logger.should be(base.logger)
    end
  end
end