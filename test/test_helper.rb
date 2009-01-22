require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'test/unit'
require 'mongo'

$mongo = XGen::Mongo::Driver::Mongo.new
$db = $mongo.db('activerecord-mongo-adapter-test')

require 'mongo_record'
