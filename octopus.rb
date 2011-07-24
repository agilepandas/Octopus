require 'yaml'
require 'rubygems'
require 'sinatra/base'
require 'logger'
require 'cinch'
require 'active_support/inflector'

require File.dirname(__FILE__) + '/octopus/base'
require File.dirname(__FILE__) + '/octopus/plugin'
require File.dirname(__FILE__) + '/octopus/sinatra'
require File.dirname(__FILE__) + '/octopus/wrapper'
require File.dirname(__FILE__) + '/octopus/plugins/plugin'

environment = (ENV["OCTOPUS_ENV"] || "development").to_sym

octopus = Octopus::Base.new(environment)

octopus.run!