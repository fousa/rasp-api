require File.join(File.dirname(__FILE__), '..', 'app.rb')

require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'
require 'json'
require 'net/http'

# set test environment
set :environment,  :test
set :run,          false
set :raise_errors, true
set :logging,      false
