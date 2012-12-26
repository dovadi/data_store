module DataStore

  # Used to set up and modify settings for the data store.
  class Configuration

    # The prefix is used as a prefix for the database table name.
    attr_accessor :prefix

    # The database used for storing the data.
    attr_accessor :database

    # The compression factor is the level of compression of your historical data.
    attr_accessor :compression_factor

    # The frequency tells how often data entry is done.
    # A frequency of 10 means a data entry once every 10 seconds.
    attr_accessor :frequency

    # The maximum datapoints is the maximum number of datapoint within a given timeframe
    attr_accessor :maximum_datapoints

    # The data type in which the value is stored
    attr_accessor :data_type

    def initialize
      @prefix             = 'data_store_'
      @database           = :postgres
      @compression_factor = 5
      @frequency          = 10
      @maximum_datapoints = 800
      @data_type          = :float
    end

  end

end
