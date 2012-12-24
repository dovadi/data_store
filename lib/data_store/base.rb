module DataStore

  class Base

    # Create a record in the data_stores table with the following attributes
    #
    # * primary_key :id
    # * Integer     :identifier, unique: true, null: false
    # * String      :name, null: false
    # * String      :type, null: false
    # * String      :description
    # * DateTime    :created_at
    # * DateTime    :updated_at
    # * index       :identifier
    def self.create(attributes)
      dataset.insert(attributes.merge(created_at: Time.now, updated_at: Time.now))
      dataset.order('created_at DESC').last
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
      @database ||= begin
        case DataStore.configuration.database
        when :sqlite3
          Sequel.sqlite(File.expand_path('../../../db/data_store.db', __FILE__))
        end
      end
    end

  end

end