module DataStore

  class Base

    # Create a record in the data_stores table with the following attributes
    #
    # * primary_key :id
    # * Integer     :identifier, unique: true, null: false
    # * String      :name, null: false
    # * String      :type, null: false
    # * String      :description
    def self.create(attributes)
      dataset.insert(attributes.merge(created_at: Time.now, updated_at: Time.now))
      dataset.order(:created_at).last
    end

    private

    def self.dataset
      begin
        database[:data_stores] if database[:data_stores].count
      rescue Sequel::DatabaseError
        DataStore.data_stores_migration.apply(database, :up)
        database[:data_stores]
      end
    end

    def self.database
      @database ||= Sequel.connect(database_configuration)
    end

    def self.database_configuration
      config_file = File.expand_path('../../../config/database.yml', __FILE__)
      YAML.load(File.open(config_file))[DataStore.configuration.database.to_s]
    end

  end

end