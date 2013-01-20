module DataStore

  # Used to set up and modify settings for the data store.
  class Configuration

    # The prefix is used as a prefix for the database table name.
    attr_accessor :prefix

    # The database used for storing the data.
    attr_accessor :database

    # The schema is the way avarages of the datapoints is calculated/
    #  Default: [6,5,3,4,4,3]
    attr_accessor :compression_schema

    # The frequency tells how often data entry is done.
    # A frequency of 10 means a data entry once every 10 seconds.
    #  Default: 10 sec
    attr_accessor :frequency

    # Tolerance of the frequency in which datapoints are added
    #  Default: 0.05 
    # This means a 5% margin. So with a frequency of 10s, 
    # the next datapoint within 9.95 - 10.5 is considered the next datapoint
    attr_accessor :frequency_tolerance


    # The maximum datapoints is the maximum number of datapoint within a given timeframe
    #  Default: 800
    attr_accessor :maximum_datapoints

    # The data type in which the value is stored
    #  Default: double
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


    #Allow concurrency by calculating average values in multiple threads
    #  Default: false
    attr_accessor :allow_concurrency



    def initialize
      @prefix                      = 'ds_'
      @database                    = :postgres
      @compression_schema          = [6,5,3,4,4,3]
      @frequency                   = 10
      @maximum_datapoints          = 800
      @data_type                   = :double
      @database_config_file        = File.expand_path('../../../config/database.yml', __FILE__)
      @log_file                    = $stdout
      @log_level                   = Logger::ERROR
      @enable_logging              = true
      @allow_concurrency           = false
      @frequency_tolerance         = 0.05
    end

  end

end
