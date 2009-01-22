module MongoRecord

  # A wrapper around a Mongo database cursor. MongoRecord::Cursor is
  # Enumerable.
  #
  # Example:
  #   Person.find(:all).sort({:created_on => 1}).each { |p| puts p.to_s }
  #   n = Thing.find(:all).count()
  #   # note that you can just call Thing.count() instead
  #
  # The sort, limit, and skip methods must be called before resolving the
  # quantum state of a cursor.
  #
  # See ActiveRecord::Base#find for more information.
  class Cursor
    include Enumerable

    # Forward missing methods to the cursor itself.
    def method_missing(sym, *args, &block)
      return @cursor.send(sym, *args)
    end

    def initialize(db_cursor, model_class)
      @cursor, @model_class = db_cursor, model_class
    end

    # Iterate over the records returned by the query. Each row is turned
    # into the proper ActiveRecord::Base subclass instance.
    def each
      @cursor.each { |row| yield @model_class.send(:instantiate, row) }
    end

    # Sort, limit, and skip methods that return self (the cursor) instead of
    # whatever those methods return.
    %w(sort limit skip).each { |name|
      eval "def #{name}(*args); @cursor.#{name}(*args); return self; end"
    }
  end
end
