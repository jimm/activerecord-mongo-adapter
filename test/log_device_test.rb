require 'test_helper'
require 'mongo_record/log_device'

class LoggerTest < ActiveSupport::TestCase

  MAX_RECS = 3

  def setup
    $db.collection('testlogger').drop()
    # Create a log device with a max of MAX_RECS records
    @logger = Logger.new(MongoRecord::LogDevice.new('testlogger', :size => 1_000_000, :max => MAX_RECS))
    @log_collection = $db.collection('testlogger')
  end

  def teardown
    $db.collection('testlogger').drop()
  end

  # We really don't have to test much more than this. We can trust that Mongo
  # works properly.
  test "max records enforced" do
    assert_equal $db.name, MongoRecord::LogDevice.connection.name
    MAX_RECS.times { |i|
      @logger.debug("test message #{i+1}")
      assert_equal i+1, @log_collection.count()
    }

    MAX_RECS.times { |i|
      @logger.debug("test message #{i+MAX_RECS+1}")
      assert_equal MAX_RECS, @log_collection.count()
    }
  end

end
