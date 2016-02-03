RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + "/..")

require 'simplecov'
SimpleCov.profiles.define 'gem' do
  add_filter '/spec/'
  add_group 'Libraries', 'lib'
end

SimpleCov.start 'gem'
require 'bundler/setup'
Bundler.setup
require 'acts_as_csv'
require 'models/models'
require 'pry'
require 'active_record'
require 'nulldb_rspec'
include NullDB::RSpec::NullifiedDatabase

# NullDB is lonely and really wants to be configured
# See https://github.com/nulldb/nulldb/blob/master/lib/nulldb/rails.rb#L4
NullDB.configure {|ndb| def ndb.project_root;RAILS_ROOT;end}

# Config some more to suppress after(:all) warnings
# See https://github.com/nulldb/nulldb/blob/master/lib/nulldb_rspec.rb#L101
ActiveRecord::Base.configurations.merge!('test' => { 'adapter' => 'nulldb' })

# Here's where you force NullDB to do your bidding
RSpec.configure do |config|
  config.before(:each) do
    schema_path = File.join(RAILS_ROOT, 'spec/models/schema.rb')
    NullDB.nullify(:schema => schema_path)
  end

  config.after(:each) do
    NullDB.restore
  end
end


