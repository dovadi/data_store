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
    end

    # Pop the most recent datapoint from the stack
    def pop
      model.order(:created).last
    end

    # Return the total number of datapoints in the stack
    def count
      dataset.count
    end

    # Create the database tables which the stack usesd for storing the datapoints
    def create!
      begin
        DataStore.create_stack(stack_name).apply(database, :up)
      rescue Sequel::DatabaseError
      end
    end

    # Drop all corresponding database tables and recreate them
    def reset!
      drop!
      create!
    end

    # Return the corresponding dataset with the datapoitns
    def dataset
      database[stack_name]
    end

    private

    def drop!
      DataStore.create_stack(stack_name).apply(database, :down)
    rescue Sequel::DatabaseError
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