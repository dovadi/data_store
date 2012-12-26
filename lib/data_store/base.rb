module DataStore

  class Base

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
      begin
        DataStore.migration.apply(database, :up)
      rescue Sequel::DatabaseError
      end
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

    private

    def drop_table!
      begin
        database.drop_table :data_stores
      rescue Sequel::DatabaseError
      end
    end

    def database_settings
      config_file = File.expand_path('../../../config/database.yml', __FILE__)
      YAML.load(File.open(config_file))[DataStore.configuration.database.to_s]
    end

  end

end