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

require 'logger'
require 'mongo_record/log_device'
# Default LogDevice capped collection size is 10 Mb.
RAILS_DEFAULT_LOGGER = Logger.new(MongoRecord::LogDevice.new("rails_log_#{ENV['RAILS_ENV']}")) unless defined?(RAILS_DEFAULT_LOGGER)

# Patch Rails
require 'mongo_record/active_record'

# (Normal Rails config here).

# Use $db (defined in init.rb) as the database connection
ActiveRecord::Base.connection = $db
