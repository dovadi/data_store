module DataStore

  class Base

    # Set the default values with the globally defined values
    #  * :compression_schema
    #  * :frequency
    #  * :maximum_datapoints
    #  * :data_type
    # See {Configuration}
    def before_save
      set_default_values  
    end

    def after_create
      drop_tables!
      create_tables!
    end

    def before_destroy
      drop_tables!
    end

    # Convert serialized compression schema as a string back into the array object itself.
    # For example: "[5,4,3]" => [5,4,3]
    def compression_schema
      value = self.values[:compression_schema]
      value.gsub(/\[|\]/,'').split(',').map(&:to_i) unless value.nil?
    end

    private

    def default_values
      ['compression_schema', 'frequency', 'maximum_datapoints', 'data_type']
    end

    def set_default_values
      default_values.each do |variable|
        value = DataStore.configuration.send(variable)
        self.send(variable+ '=', value) if self.send(variable).nil?
      end
    end

    # Create the database tables which are used for storing the datapoints
    def create_tables!
      migrate(:up)
    end

    # Drop the database tables which are used for storing the datapoints
    def drop_tables!
      migrate(:down)
    end

    def table_names
      names  = [table_name.to_s]
      factor = 1
      compression_schema.each do |compression|
        factor = (factor * compression)
        names << table_name.to_s + '_' + factor.to_s
      end
      names
    end

    def migrate(direction = :up)
      # Establish new connection to prevent mix up with associated db connection of the Base object
      # Unless connected to a sqlite db, otherwise it is too time consuming
      database = sqlite_db? ? db : DataStore::Connector.new.database
      table_names.each do |name|
        begin
          DataStore.create_table(name, data_type).apply(database, direction)
        rescue Sequel::DatabaseError
        end
      end
      database.disconnect unless sqlite_db?
    end

    def table_name
      (prefix + identifier.to_s).to_sym
    end

    def prefix
      DataStore.configuration.prefix
    end

    def sqlite_db?
      DataStore.configuration.database.to_s == 'sqlite'
    end

  end

end