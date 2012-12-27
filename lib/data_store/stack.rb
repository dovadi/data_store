module DataStore

  class Stack

    attr_reader :identifier

    def initialize(identifier)
      @identifier = identifier
    end

    def parent
      @parent ||= DataStore.model.find(identifier: identifier)
    end

    # Return a Stack class enriched with Sequel::Model behaviour
    def model
      @model ||= Class.new(Sequel::Model(dataset))
    end

    def push(value)
      dataset << {value: value, created_at: Time.now.utc}
    end

    def pop
      model.order(:created_at).last
    end

    def count
      dataset.count
    end

    def create!
      begin
        DataStore.create_stack(stack_name).apply(database, :up)
      rescue Sequel::DatabaseError
      end
    end

    def reset!
      drop!
      create!
    end

    def dataset
      database[stack_name]
    end

    private

    def drop!
      begin
        database.drop_table stack_name
      rescue Sequel::DatabaseError
      end
    end

    def database
      DataStore::Connector.new.database
    end

    def stack_name
      (prefix + identifier.to_s).to_sym
    end

    def prefix
      DataStore.configuration.prefix
    end
  end

end