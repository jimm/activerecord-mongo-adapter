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

  module ConnectionAdapters

    # Override a few methods because Mongo doesn't use SQL.
    class ColumnDefinition
      def sql_type; type; end
      def to_sql; ''; end
      def add_column_options!(sql, options); ''; end
    end

    # Override a few methods because Mongo doesn't use SQL.
    class TableDefinition
      def native; {}; end
    end

    # The database connection object used by ActiveRecord to talk to Mongo.
    # Most of the actual communications with the database happens in the
    # mongo_record modifications to ActiveRecord::Base, because it is that
    # class (and its subclasses) that know what collection to talk to.
    class MongoPseudoConnection

      attr_reader :db

      def initialize(db)
        @runtime = 0
        @db = db
      end

      # We output all unknown method calls to $stderr. There shouldn't be
      # many.
      def method_missing(sym, *args)
        if $DEBUG
          $stderr.puts "#{sym}(#{args.inspect}) sent to conn"
          caller(0).each { |s| $stderr.puts s }
        end
      end

      # Return a quoted value.
      def quote(val, column=nil)
        return val unless val.is_a?(String)
        "'#{val.gsub(/\'/, "\\\\'")}'" # " <= for Emacs font-lock
      end

      # Return a quoted table name.
      def quote_table_name(str)
        str.to_s
      end

      # Return a quoted column name.
      def quote_column_name(str)
        str.to_s
      end

      # Used by ActiveRecord to record statement runtimes.
      def reset_runtime
        rt, @runtime = @runtime, 0
        rt
      end

      # Return the alias for +table_name+.
      def table_alias_for(table_name)
        table_name.gsub(/\./, '_')
      end

      # Return +false+.
      def supports_count_distinct?
        false
      end

      # Transactions are not yet supported by Mongo, so this method simply
      # yields to the given block.
      def transaction(start_db_transaction=true)
        begin
          yield
        rescue ActiveRecord::Rollback
        end
      end

      # Enable the query cache within the block. Ignored.
      def cache
        yield
      end

      # Disable the query cache within the block. Ignored.
      def uncached
        yield
      end
    end
  end
end
