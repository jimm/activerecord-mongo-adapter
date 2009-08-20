require 'test_helper'
require 'mongo_record/pk_factory'

class PKFactoryTest < Test::Unit::TestCase

  def setup
    @pkf = MongoRecord::PKFactory.new
    @known_id = Mongo::ObjectID.new
  end

  def test_generates_ObjectIDs
    assert_kind_of Mongo::ObjectID, @pkf.create_pk({})['_id']
  end

  def test_generates_unique_ids
    assert_not_equal @pkf.create_pk({})['_id'], @pkf.create_pk({})['_id']
  end

  def test_does_not_stomp_on_old_ids
    row = {'_id' => @known_id}
    @pkf.create_pk(row)
    assert_equal @known_id, row['_id']
  end

  def test_stomps_on_old_ids_when_nil
    row = {'_id' => nil}
    @pkf.create_pk(row)
    assert_not_nil row['_id']
    assert_kind_of Mongo::ObjectID, row['_id']
  end

  def test_does_not_stomp_on_old_ids_when_id_key_is_symbol
    row = {:_id => @known_id}
    @pkf.create_pk(row)
    assert_equal @known_id, row[:_id]
    assert_nil row['_id']
  end

  def test_deletes_id_symbol_key_with_nil_value
    row = {:_id => nil}
    @pkf.create_pk(row)
    assert_nil row[:_id]
    assert_not_nil row['_id']
    assert_kind_of Mongo::ObjectID, row['_id']
  end

  def test_deletes_id_symbol_key_with_nil_value_and_id_string_key
    row = {:_id => nil, '_id' => @known_id}
    @pkf.create_pk(row)
    assert_nil row[:_id]
    assert_equal @known_id, row['_id']
    assert_kind_of Mongo::ObjectID, row['_id']
  end

end
