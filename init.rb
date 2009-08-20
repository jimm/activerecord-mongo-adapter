require 'yaml'

db_config = File.open(File.join(RAILS_ROOT, 'config/database.yml'), 'r') {|f|
  YAML.load(f)
}
db_config = db_config[RAILS_ENV]

if db_config['adapter'] == 'mongo'
  begin
    require 'mongo'
  rescue
    require 'mongo'
  end
  require 'mongo_record/pk_factory'

  $db = Mongo::Mongo.new(db_config['host'], db_config['port']).db(db_config['database'], :pk => MongoRecord::PKFactory.new)
  # require this after the DB is set up, otherwise ActiveRecord::Base.connection.db does not
  # get populated
  require 'mongo_record'

  # Uncomment the following to log to Mongo using a capped collection.
#   require 'logger'
#   require 'mongo_record/log_device'
#   # Default LogDevice capped collection size is 10 Mb.
#   RAILS_DEFAULT_LOGGER = Logger.new(MongoRecord::LogDevice.new("rails_log_#{ENV['RAILS_ENV']}")) unless defined?(RAILS_DEFAULT_LOGGER)

end
