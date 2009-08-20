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

require 'mongo/types/objectid'

class String
  # Convert this String to an ObjectID.
  def to_oid
    Mongo::ObjectID.from_string(self)
  end
end

# Normally, you don't have to worry about ObjectIDs. You can treat _id values
# as strings and this code will convert them for you.
class Mongo::ObjectID
  # Convert this object to an ObjectId.
  def to_oid
    self
  end

  # Tells Marshal how to dump this object. This was used in code that stored
  # sessions in Mongo. It is unused for now.
  def marshal_dump
    to_s
  end

  # Tells Marshal how to load this object. This was used in code that stored
  # sessions in Mongo. It is unused for now.
  def marshal_load(oid)
    Mongo::ObjectID.from_string(oid)
  end
end

