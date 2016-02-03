require 'simplecov'
SimpleCov.start
require 'bundler/setup'
Bundler.setup
require 'acts_as_csv'
require 'models/order'
require 'pry'

RSpec.configure do |config|
  
end

require 'nulldb_rspec'
include NullDB::RSpec::NullifiedDatabase
ActiveRecord::Base.establish_connection :adapter => :nulldb