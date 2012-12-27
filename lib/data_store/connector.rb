module DataStore

  class Connector

    # Create the data_stores table with the following attributes
    #
    # * primary_key :id
    # * Integer     :identifier, unique: true, null: false
    # * String      :name, null: false
    # * String      :type, null: false
    # * String      :description
    # * DateTime    :created_at
    # * DateTime    :updated_at
    #
    def create_table!
      DataStore.migration.apply(database, :up)
      disconnect
    rescue Sequel::DatabaseError
    end

    # Drop data_stores table and recreate it
    def reset!
      drop_table!
      create_table!
    end

    # Return the dataset associated with data_stores
    def dataset
      @dataset ||= begin
        create_table!
        database[:data_stores]
      end
    end

    # Return the database object to which its connected.
    def database
      @database ||= Sequel.connect(database_settings)
    end

    def disconnect
      database.disconnect
      @database = nil
    end

    private
 
    def drop_table!
      DataStore.migration.apply(database, :down)
      disconnect
    rescue Sequel::DatabaseError
    end

    def database_settings
      config_file = DataStore.configuration.database_config_file
      YAML.load(File.open(config_file))[DataStore.configuration.database.to_s]
    end

  end

end