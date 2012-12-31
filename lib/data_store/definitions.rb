module DataStore

  # Definition of the data_stores table
  def self.create_data_stores
    Sequel.migration do
      change do
        create_table(:data_stores) do
          primary_key :id
          Integer     :identifier, unique: true, null: false
          String      :name, null: false
          String      :type, null: false
          String      :description
          String      :data_type
          String      :compression_schema
          Integer     :frequency
          Integer     :maximum_datapoints
          DateTime    :created_at
          DateTime    :updated_at
          index       :identifier
        end
      end
    end
  end

  def self.create_table(table_name, data_type)
    Sequel.migration do
      change do
        create_table(table_name) do
          primary_key :id
          column :value, data_type
          column :created, :double
        end
      end
    end
  end

end