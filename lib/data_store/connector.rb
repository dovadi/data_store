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
      DataStore.create_data_stores.apply(database, :up)
    rescue Sequel::DatabaseError => e
      raise e if e.message.include?('FATAL')
    end

    # Drop data_stores table and recreate it
    def reset!
      drop_table!
      create_table!
      disconnect
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
      @database ||= begin
        if RUBY_PLATFORM == 'java'
          Sequel.connect(jdbc_settings)
        else
          Sequel.connect(database_settings)
        end
      end
    end

    private

    def jdbc_settings
      settings = database_settings
      db =  case settings['adapter']
            when 'postgres'
              'postgresql'
            when 'mysql2'
              'mysql'
            else
              settings['adapter']
            end
      if db == 'sqlite'
        uri = "jdbc:#{db}:#{settings['database']}"
      else
        uri = "jdbc:#{db}://#{settings['host']}/#{settings['database']}?user=#{settings['username']}"
      end
      settings['password'] ? uri + "&password=#{settings['password']}" : uri
    end

    def disconnect
      database.disconnect
      @database = nil
    end
 
    def drop_table!
      DataStore.create_data_stores.apply(database, :down)
    rescue Sequel::DatabaseError => e
      raise e if e.message.include?('FATAL')
    end

    def database_settings
      config_file = DataStore.configuration.database_config_file
      settings = YAML.load(File.open(config_file))[DataStore.configuration.database.to_s]
      settings['adapter'] = 'postgres' if settings['adapter'] == 'postgresql'
      settings
    end

  end

end