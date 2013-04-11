##0.1.2

  * First timestamp, then value when fetching from data_store

##0.1.1

  * Add index in table definition

##0.1.0

  * Move away from Celluloid. To many problems in a web application with Puma.

##0.0.9

 * Bug fix: connect to database in case of a DATABASE_URL now works wiht JRuby as well

##0.0.8

 * Connect to database in case of a DATABASE_URL environment variable (used with Heroku)

##0.0.7

  * Partial rollback: sequel and celluloid again part of the gemspec

##0.0.6

  * Move gem dependencies from gemspec to Gemfile in order to install correctly on JRuby

##0.0.5

  * Bug fix typo '==' instead of '='

##0.0.4

  * Useable with database.yml as used in Rails (postgresql adapter)

##0.0.3

  * Move dependencies to gemspec

##0.0.2

  * Readme driven development
  * Configuration of DataStore with Connector class for database connection and dataset definition
  * Introduction of DataStore::Base enriched behaviour with the use of Sequel::Model
  * introduction of the DataStore::Table to add datapoints
  * First working release

##0.0.1

  * Initial commit and release of gem