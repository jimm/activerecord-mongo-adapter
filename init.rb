require 'mongo'
require 'yaml'
require 'mongo_record/pk_factory'

db_config = File.open(File.join(RAILS_ROOT, 'config/database.yml'), 'r') {|f|
  YAML.load(f)
}
db_config = db_config[RAILS_ENV]
if db_config['adapter'] == 'mongo'
  $db = XGen::Mongo::Driver::Mongo.new(db_config['host'], db_config['port']).db(db_config['database'], :pk => MongoRecord::PKFactory.new)
  require 'mongo_record'
end
