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

  context 'Database on Heroku' do

    setup do
      ENV['DATABASE_URL'] = if RUBY_PLATFORM == 'java'
       "jdbc:postgresql://localhost/data_store_test?user=postgres"
      else
       'postgres://postgres@localhost/data_store_test'
      end
    end

    should 'connect on the base of the DATABASE_URL environment variable if exists' do
      DataStore.configuration.stubs(:database_config_file).returns('')
      @connector = DataStore::Connector.new
      assert @connector.database.inspect.gsub('?','').match(ENV['DATABASE_URL']) #Remove ? otherwise match fails
    end

    teardown do
      @connector.database.disconnect
      ENV['DATABASE_URL'] = nil
    end

  end

end