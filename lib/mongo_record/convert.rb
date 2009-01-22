class Object
  # Convert an Object to a Mongo value. Used when saving data to Mongo.
  def to_mongo_value
    self
  end
end

class Array
  # Convert an Array to a Mongo value. Used when saving data to Mongo.
  def to_mongo_value
    self.collect {|v| v.to_mongo_value}
  end
end

class Hash
  # Convert an Hash to a Mongo value. Used when saving data to Mongo.
  def to_mongo_value
    h = {}
    self.each {|k,v| h[k] = v.to_mongo_value}
    h
  end
end
