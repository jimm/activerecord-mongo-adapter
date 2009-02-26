#--
# Copyright (C) 2009 10gen Inc.
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

module ActiveRecord

  # The Mongo implementation of ActiveRecord needs to read the file named by
  # ENV['SCHEMA'] or, if that is not defined, db/schema.rb to get the database
  # schema the application wants to use, because Mongo is schema-free.
  #
  # Here we override some ActiveRecord::Schema methods here that get used when
  # reading the schema file.
  #
  # Since this class is only used by the Mongo ActiveRecord code to read a
  # schema file, we don't have to worry about handling database and table
  # modification statements like drop_table or remove_column.
  class Schema

    cattr_reader :collection_info
    @@collection_info = {}

    class << self

      def define(info={}, &block)
        self.verbose = false
        @collection_info = {}
        instance_eval(&block)
      end

      def create_table(name, options)
        t = ActiveRecord::ConnectionAdapters::TableDefinition.new(self)
        t.primary_key('_id')
        @@collection_info[name] = t
        yield t
      end

      def add_index(table_name, column_name, options = {})
        ActiveRecord::Base.connection.db.collection(table_name).create_index(column_name)
      end
    end

  end
end
