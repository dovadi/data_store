module DataStore

  class Table

    include Celluloid

    attr_reader :identifier, :table_index, :original_value

    # Initialize the table by passsing an identifier
    def initialize(identifier, table_index = 0)
      @identifier  = identifier
      @table_index = table_index
    end

    # Return a the corresponding parent class, i.e the settings from the data_stores table
    def parent
      @parent ||= DataStore::Base.find(identifier: identifier)
    end

    # Return a table object enriched with Sequel::Model behaviour
    def model
      @model ||= Class.new(Sequel::Model(dataset))
    end

    # Add a new datapoint to the table
    # In case of a counter type, store the difference between current and last value
    # And calculates average values on the fly according to compression schema
    #
    # Options (hash):
    #  * created: timestamp
    #  * type: gauge or counter
    #  * table_index: in which compressed table
    def add(value, options = {})
      created      = options[:created] || Time.now.utc.to_f
      type         = options[:type] || parent.type
      @table_index = options[:table_index] if options[:table_index]
      push(value, type, created)
    end

    # Return the most recent datapoint added
    def last
      model.order(:created).last
    end

    # Return the total number of datapoints in the table
    def count
      dataset.count
    end

    # Return the corresponding dataset with the datapoitns
    def dataset
      database[table_name]
    end

    # Fetch the corresponding datapoints
    #
    # Options:
    #  * :from
    #  * :till
    #
    def fetch(options)
      datapoints = []
      query = parent.db[timeslot(options)].where{created >= options[:from]}.where{created <= options[:till]}.order(:created)
      query.all.map{|record| datapoints <<[record[:value], record[:created]]}
      datapoints
    end

    # Import original datapoints, mostly to recreate compression tables
    def import(datapoints)
      datapoints.each do |data|
        add!(data[0], table_index: 0, created: data[1])
      end      
    end

    private

    def timeslot(options)
      distance = options[:till] - options[:from]
      index = 0
      parent.time_borders.each_with_index do |value, idx|
        index = idx
        break if value >= distance
      end
      parent.table_names[index]
    end

    def push(value, type, created)
      value = difference_with_previous(value) if type.to_s == 'counter'
      datapoint = { value: value, created: created }
      datapoint[:original_value] = original_value if original_value
      dataset << datapoint
      calculate_average_values
    end

    def calculate_average_values
      calculator = AverageCalculator.new(self)
      calculator.perform
    end

    def difference_with_previous(value)
      @original_value = value
      unless last.nil?
        value = value - last[:original_value]
        last.delete if last[:value] == last[:original_value]
      end
      value
    end

    def database
      @database ||= DataStore::Base.db
    end

    def table_name
      parent.table_names[table_index]
    end

  end

end