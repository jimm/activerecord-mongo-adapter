#--
# Copyright (C) 2008 10gen Inc.
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License, version 3, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
# for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#++

module MongoRecord

  # A destination for Ruby's built-in Logger class. It writes log messages
  # to a Mongo database collection. Each item in the collection consists
  # of two fields (besides the _id): +time+ and +msg+. +time+ is
  # automatically generated when +write+ is called.
  #
  # If we are running outside of the cloud, all log messages are echoed to
  # $stderr.
  #
  # The collection is capped, which means after the limit is reached old
  # records are deleted when new ones are inserted. See the new method and the
  # Mongo documentation for details.
  #
  # Example:
  #
  #   logger = Logger.new(MongoRecord::LogDevice('my_log_name'))
  #
  # The database connection defaults to the global $db. You can set the
  # connection using MongoRecord::LogDevice.connection= and read it with
  # MongoRecord::LogDevice.connection.
  #
  #   # Set the connection to something besides $db
  #   MongoRecord::LogDevice.connection = connect('my-database')
  class LogDevice

    DEFAULT_CAP_SIZE = (10 * 1024 * 1024)

    @@connection = nil

    class << self # Class methods

      # Return the database connection. The default value is <code>$db</code>.
      def connection
        conn = @@connection || $db
        raise "connection not defined" unless conn
        conn
      end

      # Set the database connection. If the connection is set to +nil+, then
      # <code>$db</code> will be used.
      def connection=(val)
        @@connection = val
      end

    end

    # +name+ is the name of the Mongo database collection that will hold all
    # log messages. +options+ is a hash that may have the following entries:
    #
    # <code>:size</code> - Optional. The max size of the collection, in
    # bytes. If it is nil or negative then +DEFAULT_CAP_SIZE+ is used.
    #
    # <code>:max</code> - Optional. Specifies the maximum number of log
    # records, after which the oldest items are deleted as new ones are
    # inserted.
    #
    # Note: a non-nil :max requires a :size value. The collection will never
    # grow above :size. If you leave :size nil then it will be
    # +DEFAULT_CAP_SIZE+.
    #
    # <code>:console</code> - Optional. Specifies an IO instance (for example,
    # $stdout, $stderr, or an open file) that will receive copies of each log
    # message.
    #
    # Note: once a capped collection has been created, you can't redefine the
    # size or max falues for that collection. To do so, you must drop and
    # recreate (or let a LogDevice object recreate) the collection.
    def initialize(name, options = {})
      @collection_name = name
      options[:size] ||= DEFAULT_CAP_SIZE
      options[:size] = DEFAULT_CAP_SIZE if options[:size] <= 0
      options[:capped] = true
      @console = options.delete[:echo]

      # It's OK to call createCollection if the collection already exists.
      # Size and max won't change, though.
      #
      # Note we can't use the name "create_collection" because a DB JSObject
      # does not have normal keys and returns collection objects as the value
      # of all unknown names.
      self.class.connection.createCollection(@collection_name, options)
    end

    # Write a log message to the database. We save the message and a timestamp.
    def write(str)
      @console.puts str if @console
      self.class.connection[@collection_name].save({:time => Time.now, :msg => str})
    end

    # Close the log. This method is a sham. Nothing happens. You may
    # continue to use this LogDevice.
    def close
    end
  end
end
