require 'sequel'
require 'yaml'
require 'data_store/version'
require 'data_store/connector'
require 'data_store/configuration'
require 'data_store/migration'
require 'data_store/stack'

Sequel.extension :migration
Sequel::Model.plugin :timestamps, :force=>true, :update_on_create=>true

module DataStore

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
      connector = DataStore::Connector.new
      connector.create_table!
      connector.database.disconnect
    end

    # The configuration object. See {Configuration}
    def configuration
      @configuration ||= Configuration.new
    end

    # Return a DataStore class enriched with Sequel::Model behaviour
    def model(dataset = [])
      if dataset.empty?
        connector = DataStore::Connector.new
        dataset = connector.dataset
        connector.disconnect
      end
      Class.new(Sequel::Model(dataset))
    end

  end

end

