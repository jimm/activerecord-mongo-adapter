require 'test_helper'
require 'mongo_record/pk_factory'

class PKFactoryTest < ActiveSupport::TestCase

  def setup
    @pkf = MongoRecord::PKFactory.new
    @known_id = XGen::Mongo::Driver::ObjectID.new
  end

  test "generates ObjectIDs" do
    assert_kind_of XGen::Mongo::Driver::ObjectID, @pkf.create_pk({})['_id']
  end

  test "generates unique ids" do
    assert_not_equal @pkf.create_pk({})['_id'], @pkf.create_pk({})['_id']
  end

  test "does not stomp on old ids" do
    row = {'_id' => @known_id}
    @pkf.create_pk(row)
    assert_equal @known_id, row['_id']
  end

  test "stomps on old ids when nil" do
    row = {'_id' => nil}
    @pkf.create_pk(row)
    assert_not_nil row['_id']
    assert_kind_of XGen::Mongo::Driver::ObjectID, row['_id']
  end

  test "does not stomp on old ids when id key is symbol" do
    row = {:_id => @known_id}
    @pkf.create_pk(row)
    assert_equal @known_id, row[:_id]
    assert_nil row['_id']
  end

  test "deletes id symbol key with nil value" do
    row = {:_id => nil}
    @pkf.create_pk(row)
    assert_nil row[:_id]
    assert_not_nil row['_id']
    assert_kind_of XGen::Mongo::Driver::ObjectID, row['_id']
  end

end
