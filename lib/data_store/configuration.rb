module DataStore

  # Used to set up and modify settings for the data store.
  class Configuration

    # The prefix is used as a prefix for the database table name.
    attr_accessor :prefix

    # The database used for storing the data.
    attr_accessor :database

    # The schema is the way avarages of the datapoints is calculated/
    attr_accessor :compression_schema

    # The frequency tells how often data entry is done.
    # A frequency of 10 means a data entry once every 10 seconds.
    attr_accessor :frequency

    # The maximum datapoints is the maximum number of datapoint within a given timeframe
    attr_accessor :maximum_datapoints

    # The data type in which the value is stored
    attr_accessor :data_type

    #The location of the database.yml file
    attr_accessor :database_config_file

    #Enable logging. 
    #  Default: true
    attr_accessor :enable_logging

    #The location of the log file
    #  Default $stdout
    attr_accessor :log_file

    #The level of logging
    #  Default: Logger::ERROR
    attr_accessor :log_level


    def initialize
      @prefix               = 'ds_'
      @database             = :postgres
      @compression_schema   = [6,5,3,4,4,3]
      @frequency            = 10
      @maximum_datapoints   = 800
      @data_type            = :double
      @database_config_file = File.expand_path('../../../config/database.yml', __FILE__)
      @log_file             = $stdout
      @log_level            = Logger::ERROR
      @enable_logging       = true
    end

  end

end
