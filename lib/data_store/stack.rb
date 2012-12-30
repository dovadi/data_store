module DataStore

  class Stack

    attr_reader :identifier

    # Initialize the stack by passsing an identifier
    def initialize(identifier)
      @identifier = identifier
    end

    # Return a the corresponding parent class, i.e the settings from the data_stores table
    def parent
      @parent ||= DataStore::Base.find(identifier: identifier)
    end

    # Return a Stack object enriched with Sequel::Model behaviour
    def model
      @model ||= Class.new(Sequel::Model(dataset))
    end

    # Push a new datapoint on the stack
    def push(value)
      dataset << {value: value, created: Time.now.utc.to_f}
      calculate_average_values
    end

    # Return the most recent datapoint added
    def last
      model.order(:created).last
    end

    # Return the total number of datapoints in the stack
    def count
      dataset.count
    end

    # Create the database tables which the stack usesd for storing the datapoints
    def create!
      migrate(:up)
    end

    # Drop all corresponding database tables and recreate them
    def reset!
      migrate(:down)
      create!
    end

    # Return the corresponding dataset with the datapoitns
    def dataset
      database[stack_name]
    end

    private

    def calculate_average_values
      calculator = AverageCalculator.new(identifier)
      calculator.perform
    end

    def stack_table_names
      names  = [stack_name]
      factor = 1
      parent.compression_schema.each do |compression|
        factor = (factor * compression)
        names << stack_name.to_s + '_' + factor.to_s
      end
      names
    end

    def migrate(direction = :up)
      stack_table_names.each do |name|
        begin
          DataStore.create_stack(name).apply(database, direction)
        rescue Sequel::DatabaseError
        end
      end
    end

    def database
      @database ||= DataStore::Base.db
    end

    def stack_name
      (prefix + identifier.to_s).to_sym
    end

    def prefix
      DataStore.configuration.prefix
    end
  end

end