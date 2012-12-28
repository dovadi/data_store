# encoding: UTF-8

require 'sequel'
require 'yaml'
require 'data_store/version'
require 'data_store/connector'
require 'data_store/configuration'
require 'data_store/definitions'
require 'data_store/stack'

Sequel.extension :migration
Sequel::Model.plugin :timestamps, :force=>true, :update_on_create=>true


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
      connector = DataStore::Connector.new
      connector.create_table!
      redefine_base_class(connector.dataset)
      connector.database.disconnect
    end

    # The configuration object. See {Configuration}
    def configuration
      @configuration ||= Configuration.new
    end

    private

    def redefine_base_class(dataset)
      suppress_warnings { self.const_set(:Base, Class.new(Sequel::Model(dataset)))}
      Base.plugin :serialization, :marshal, :schema
      Base.plugin :hook_class_methods
      Base.send(:define_method, :before_save) do
        ['schema', 'frequency', 'maximum_datapoints', 'data_type'].each do |variable|
          value    = DataStore.configuration.send(variable)
          self.send(variable+ '=', value) if self.send(variable).nil?
        end
      end
    end

  end

end
