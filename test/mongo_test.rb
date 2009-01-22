require 'test_helper'

class MongoRecordTest < ActiveSupport::TestCase

  test "can connect to database" do
    assert_not_nil $db
    list = $db.collection_names
    assert_not_nil list
    assert_kind_of Array, list
  end

  test "can see database names" do
    list = $mongo.database_names
    assert_not_nil list
    assert list.size > 0
    assert list.include?('admin')
  end

end
