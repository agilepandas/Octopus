module Octopus
  class Sinatra < Sinatra::Base
    class << self
      attr_accessor :owner, :message, :username, :password
     end
  
    post "/say" do
     protected!
     Octopus::Sinatra.owner.message = {:message => params[:message], :channel => params[:channel]}
    end
       
    get "/say/:plugin/:channel/:message" do
      protected!
      Octopus::Sinatra.owner.message = {:message => params[:message], :channel => params[:channel], :plugin => params[:plugin]}
    end
    
    helpers do
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end
    
      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ["test","test"]
      end

    end
  end
end