# encoding: UTF-8

require 'sequel'
require 'yaml'
require 'logger'
require 'celluloid'

$: << File.expand_path('../', __FILE__)
$: << File.expand_path('../data_store/', __FILE__)

Sequel.extension :migration
Sequel::Model.plugin :timestamps, :force=>true, :update_on_create=>true

require 'data_store/version'
require 'data_store/connector'
require 'data_store/configuration'
require 'data_store/definitions'
require 'data_store/table'
require 'data_store/average_calculator'

module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end
end

module DataStore

  # Base class will be redefined during configure
  # In order to assign Sequel::Model behaviour to it
  # with the correctly defined (or configured) database connector
  class Base
  end
    
  class << self

    # Configure DataStore
    #
    # Example
    #   DataStore.configure |config|
    #     config.prefix   = 'data_store_'
    #     config.database = :postgres
    #   end
    def configure
      yield(configuration)
      define_base_class
    end

    # The configuration object. See {Configuration}
    def configuration
      @configuration ||= Configuration.new
    end

    private

    def define_base_class
      connector = DataStore::Connector.new
      set_logger(connector.database)
      connector.create_table!
      suppress_warnings { self.const_set(:Base, Class.new(Sequel::Model(connector.dataset)))}
      load 'base.rb'
      connector.database.disconnect
    end

    def set_logger(db)
      if configuration.enable_logging
        logger = Logger.new(configuration.log_file)
        logger.level = configuration.log_level
        db.logger = logger
      end
    end

  end

end
