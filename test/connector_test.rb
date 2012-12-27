require File.expand_path '../test_helper', __FILE__

class ConnectorTest < Test::Unit::TestCase

  context 'DataStore::Connector connection with database' do

    setup do
      @connector = DataStore::Connector.new
    end

    should 'return the postgres database if so defined' do
      DataStore.configure {|config| config.database = :postgres }
      assert_equal 'Sequel::Postgres::Database', @connector.database.class.to_s
    end

    should 'return the mysql database if so defined' do
      DataStore.configure {|config| config.database = :mysql }
      assert_equal 'Sequel::Mysql2::Database', @connector.database.class.to_s
    end

    should 'return the sqlite database if so defined' do
      DataStore.configure {|config| config.database = :sqlite }
      assert_equal 'Sequel::SQLite::Database', @connector.database.class.to_s
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
      @connector.disconnect
    end

  end

end