require 'test_helper'

class MongoRecordTest < Test::Unit::TestCase

  def test_can_connect_to_database
    assert_not_nil $db
    list = $db.collection_names
    assert_not_nil list
    assert_kind_of Array, list
  end

  def test_can_see_database_names
    $db.collection('ar-mongo-adapter').insert('a' => 1)

    list = $mongo.database_names
    assert_not_nil list
    assert list.size > 0
    assert list.include?('admin')

    $db.collection('ar-mongo-adapter').clear
  end

end
