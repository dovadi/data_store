require 'sequel'
require 'yaml'
require 'data_store/version'
require 'data_store/connector'
require 'data_store/configuration'
require 'data_store/migration'

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
      DataStore::Connector.new.create_table!
    end

    # The configuration object. See {Configuration}
    def configuration
      @configuration ||= Configuration.new
    end

    # Return a DataStore class enriched with Sequel::Model behaviour
    def model(dataset = [])
      @model ||= begin
        dataset = DataStore::Connector.new.dataset if dataset.empty?
        Class.new(Sequel::Model(dataset))
      end
    end

  end

end

