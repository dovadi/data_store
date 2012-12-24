module DataStore

  def self.data_stores_migration
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

end