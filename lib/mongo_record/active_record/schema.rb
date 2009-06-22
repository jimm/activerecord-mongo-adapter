# Copyright 2009 10gen, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
