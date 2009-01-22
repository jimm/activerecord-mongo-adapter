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

require 'mongo/types/objectid'

class String
  # Convert this String to an ObjectID.
  def to_oid
    XGen::Mongo::Driver::ObjectID.from_string(self)
  end
end

# Normally, you don't have to worry about ObjectIDs. You can treat _id values
# as strings and this code will convert them for you.
class XGen::Mongo::Driver::ObjectID
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
    XGen::Mongo::Driver::ObjectID.from_string(oid)
  end
end

