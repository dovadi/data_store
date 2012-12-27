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
          DateTime    :created_at
          DateTime    :updated_at
          index       :identifier
        end
      end
    end
  end

  def self.create_stack(table_name)
    Sequel.migration do
      change do
        create_table(table_name) do
          primary_key :id
          Float       :value
          Float       :created
        end
      end
    end
  end

end