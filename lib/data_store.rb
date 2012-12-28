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
      set_default_values
      convert_compression_schema_string_into_array
     end

    def set_default_values
      Base.send(:define_method, :before_save) do
        ['compression_schema', 'frequency', 'maximum_datapoints', 'data_type'].each do |variable|
          value = DataStore.configuration.send(variable)
          self.send(variable+ '=', value) if self.send(variable).nil?
        end
      end
    end

    def convert_compression_schema_string_into_array
      Base.send(:define_method, :compression_schema) do
        value = self.values[:compression_schema]
        eval(value) if value.is_a?(String) #convert string into array
      end
    end

  end

end
