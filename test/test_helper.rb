require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'test/unit'
require 'mongo'
require 'mongo_record/pk_factory'

# Tell Mongo adapter where to find schema file for testing.
ENV['SCHEMA'] = File.join(File.dirname(__FILE__), 'schema.rb')

$mongo = XGen::Mongo::Driver::Mongo.new(ENV['MONGO_RUBY_DRIVER_HOST'], ENV['MONGO_RUBY_DRIVER_PORT'])
$db = $mongo.db('activerecord-mongo-adapter-test', :pk => MongoRecord::PKFactory.new)
