module DataStore

  class Table

    attr_reader :identifier, :table_index

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
    def add(value, table_index = nil, type = parent.type, created = Time.now.utc.to_f )
      @table_index = table_index if table_index
      if type.to_s == 'counter'
        original_value = value
        unless last.nil?
          value = value - last[:original_value]
          last.delete if last[:value] == last[:original_value]
        end
      end
      push(value, original_value, created)
      calculate_average_values
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

    def import(datapoints)
      datapoints.each do |data|
        add(data[0], 0, :gauge, data[1])
      end      
    end

    private

    def push(value, original_value, created)
      datapoint = { value: value, created: created }
      datapoint[:original_value] = original_value if original_value
      dataset << datapoint
    end

    def calculate_average_values
      calculator = AverageCalculator.new(self)
      DataStore.configuration.allow_concurrency ? calculator.perform! : calculator.perform
    end

    def database
      @database ||= DataStore::Base.db
    end

    def table_name
      parent.table_names[table_index]
    end

  end

end