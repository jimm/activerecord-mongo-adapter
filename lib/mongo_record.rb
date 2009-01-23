
# Patch Rails
require 'mongo_record/active_record'

# Use $db (defined in init.rb) as the database connection
ActiveRecord::Base.connection = $db
