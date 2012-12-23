require 'data_store/version'
require 'data_store/configuration'

module DataStore

    # A DataStore configuration object.
    # @see Airbrake::Configuration.
    attr_writer :configuration

  class << self
     
    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   DataStore.configure do |config|
    #     config.prefix   = 'data_store'
    #     config.database = :mysql
    #   end
    def configure
      yield(configuration)
    end

    # The configuration object.
    # @see DataStore.configure
    def configuration
      @configuration ||= Configuration.new
    end

  end

end
