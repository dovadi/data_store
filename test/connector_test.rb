require File.expand_path '../test_helper', __FILE__

class ConnectorTest < Test::Unit::TestCase

  context 'DataStore::Connector connection with database' do

    setup do
      @connector = DataStore::Connector.new
    end

    should 'trigger the migration to create the database table' do
      migration = mock
      DataStore.expects(:create_data_stores).returns(migration)
      migration.expects(:apply)
      @connector.create_table!
    end

    should 'reset by dropping and recreating the database table' do
      migration = mock
      @connector.expects(:drop_table!)
      DataStore.expects(:create_data_stores).returns(migration)
      migration.expects(:apply)
      @connector.reset!
    end

    teardown do
      @connector.database.disconnect
    end

  end

end