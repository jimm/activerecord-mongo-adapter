require 'test_helper'
require 'mongo'

class MongoRecordTest < ActiveSupport::TestCase

  def setup
    @mongo = XGen::Mongo::Driver::Mongo.new
  end

  test "can see database names" do
    list = @mongo.database_names
    assert_not_nil list
    assert list.size > 0
    assert list.include?('admin')
  end

  test "can connect to database" do
    db = @mongo.db('mongo_record_test')
    assert_not_nil db
    list = db.collection_names
    assert_not_nil list
    assert_kind_of Array, list
  end
end
