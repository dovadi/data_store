module DataStore

  class Table

    attr_reader :identifier

    # Initialize the table by passsing an identifier
    def initialize(identifier)
      @identifier = identifier
    end

    # Return a the corresponding parent class, i.e the settings from the data_stores table
    def parent
      @parent ||= DataStore::Base.find(identifier: identifier)
    end

    # Return a table object enriched with Sequel::Model behaviour
    def model
      @model ||= Class.new(Sequel::Model(dataset))
    end

    # Add a new datapoint on the table
    def add(value)
      dataset << {value: value, created: Time.now.utc.to_f}
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

    # # Create the database tables which are used for storing the datapoints
    # def create!
    #   migrate(:up)
    # end

    # # Drop the database tables which are used for storing the datapoints
    # def drop!
    #   migrate(:down)
    # end

    # Return the corresponding dataset with the datapoitns
    def dataset
      database[table_name]
    end

    private

    def calculate_average_values
      calculator = AverageCalculator.new(identifier)
      calculator.perform
    end

    # def table_names
    #   names  = [table_name]
    #   factor = 1
    #   parent.compression_schema.each do |compression|
    #     factor = (factor * compression)
    #     names << table_name.to_s + '_' + factor.to_s
    #   end
    #   names
    # end

    # def migrate(direction = :up)
    #   table_names.each do |name|
    #     begin
    #       DataStore.create_table(name).apply(database, direction)
    #     rescue Sequel::DatabaseError
    #     end
    #   end
    # end

    def database
      @database ||= DataStore::Base.db
    end

    def table_name
      (prefix + identifier.to_s).to_sym
    end

    def prefix
      DataStore.configuration.prefix
    end
  end

end