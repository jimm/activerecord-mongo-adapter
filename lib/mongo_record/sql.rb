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

module MongoRecord

  module SQL

    # A simple tokenizer for SQL.
    class Tokenizer

      attr_reader :sql

      def initialize(sql)
        @sql = sql
        @length = sql.length
        @pos = 0
        @extra_tokens = []
      end

      # Push +tok+ onto the stack.
      def add_extra_token(tok)
        @extra_tokens.push(tok)
      end

      # Skips whitespace, setting @pos to the position of the next
      # non-whitespace character. If there is none, @pos will == @length.
      def skip_whitespace
        while @pos < @length && [" ", "\n", "\r", "\t"].include?(@sql[@pos,1])
          @pos += 1
        end
      end

      # Return +true+ if there are more non-whitespace characters.
      def more?
        skip_whitespace
        @pos < @length
      end

      # Return the next string without its surrounding quotes. Assumes we have
      # already seen a quote character.
      def next_string(c)
        q = c
        @pos += 1
        t = ''
        while @pos < @length
          c = @sql[@pos, 1]
          case c
          when q
            if @pos + 1 < @length && @sql[@pos + 1, 1] == q # double quote
              t += q
              @pos += 1
            else
              @pos += 1
              return t
            end
          when '\\'
            @pos += 1
            return t if @pos >= @length
            t << @sql[@pos, 1]
          else
            t << c
          end
          @pos += 1
        end
        raise "unterminated string in SQL: #{@sql}"
      end

      # Return +true+ if the next character is a legal starting identifier
      # character.
      def identifier_char?(c)
        c =~ /[\.a-zA-Z0-9_]/ ? true : false
      end

      # Return +true+ if +c+ is a single or double quote character.
      def quote?(c)
        c == '"' || c == "'"
      end

      # Return the next token, or +nil+ if there are no more.
      def next_token
        return @extra_tokens.pop unless @extra_tokens.empty?

        skip_whitespace
        c = @sql[@pos, 1]
        return next_string(c) if quote?(c)

        first_is_identifier_char = identifier_char?(c)
        t = c
        @pos += 1
        while @pos < @length
          c = @sql[@pos, 1]
          break if c == ' '

          this_is_identifier_char = identifier_char?(c)
          break if first_is_identifier_char != this_is_identifier_char && @length > 0
          break if !this_is_identifier_char && quote?(c)

          t << c
          @pos += 1
        end

        case t
        when ''
          nil
        when /^\d+$/
          t.to_i
        else
          t
        end
      end

    end

    # Only parses simple WHERE clauses right now. The parser returns a query
    # Hash suitable for use by Mongo.
    class Parser

      # Parse a WHERE clause (without the "WHERE") ane return a query Hash
      # suitable for use by Mongo.
      def self.parse_where(sql, remove_table_names=false)
        Parser.new(Tokenizer.new(sql)).parse_where(remove_table_names)
      end

      def initialize(tokenizer)
        @tokenizer = tokenizer
      end

      # Given a regexp string like '%foo%', return a Regexp object. We set
      # Regexp::IGNORECASE so that all regex matches are case-insensitive.
      def regexp_from_string(str)
        if str[0,1] == '%'
          str = str[1..-1]
        else
          str = '^' + str
        end

        if str[-1,1] == '%'
          str = str[0..-2]
        else
          str = str + '$'
        end
        Regexp.new(str, Regexp::IGNORECASE)
      end

      # Parse a WHERE clause (without the "WHERE") and return a query Hash
      # suitable for use by Mongo.
      def parse_where(remove_table_names=false)
        filters = {}
        done = false
        while !done && @tokenizer.more?
          name = @tokenizer.next_token
          raise "sql parser can't handle nested stuff yet: #{@tokenizer.sql}" if name == '('
          name.sub!(/.*\./, '') if remove_table_names # Remove "schema.table." from "schema.table.col"

          op = @tokenizer.next_token
          op += (' ' + @tokenizer.next_token) if op.downcase == 'not'
          op = op.downcase

          val = @tokenizer.next_token

          case op
          when "="
            filters[name] = val
          when "<"
            filters[name] = { :$lt => val }
          when "<="
            filters[name] = { :$lte => val }
          when ">"
            filters[name] = { :$gt => val }
          when ">="
            filters[name] = { :$gte  => val }
          when "<>", "!="
            filters[name] = { :$ne => val }
          when "like"
            filters[name] = regexp_from_string(val)
          when "in"
            raise "'in' must be followed by a list of values: #{@tokenizer.sql}" unless val == '('
            filters[name] = { :$in => read_array }
          when "between"
            conjunction = @tokenizer.next_token.downcase
            raise "syntax error: expected 'between X and Y', but saw '" + conjunction + "' instead of 'and'" unless conjunction == 'and'
            val2 = @tokenizer.next_token
            val2, val = val, val2 if val > val2 # Make sure val <= val2
            filters[name] = { :$gte => val, :$lte => val2 }
          else
            raise "can't handle sql operator [#{op}] yet: #{@tokenizer.sql}"
          end

          break unless @tokenizer.more?

          tok = @tokenizer.next_token.downcase
          case tok
          when 'and'
            next
          when 'or'
              raise "sql parser can't handle ors yet: #{@tokenizer.sql}"
          when 'order', 'group', 'limit'
            @tokenizer.add_extra_token(tok)
            done = true
          else
            raise "can't handle [#{tok}] yet"
          end
        end
        filters
      end

      private

      # Read and return an array of values from a clause like "('a', 'b',
      # 'c')". We have already read the first '('.
      def read_array
        vals = []
        while @tokenizer.more?
          vals.push(@tokenizer.next_token)
          sep = @tokenizer.next_token
          return vals if sep == ')'
          raise "missing ',' in 'in' list of values: #{@tokenizer.sql}" unless sep == ','
        end
        raise "missing ')' at end of 'in' list of values: #{@tokenizer.sql}"
      end
    end

  end
end
