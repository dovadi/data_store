require File.expand_path '../test_helper', __FILE__

class ConnectorTest < Test::Unit::TestCase

  context 'DataStore::Connector connection with database' do

    setup do
      @connector = DataStore::Connector.new
    end

    should 'return the postgres database if so defined' do
      DataStore.configuration.database = :postgres
      assert_equal 'Sequel::Postgres::Database', @connector.database.class.to_s
    end

    should 'return the mysql database if so defined' do
      DataStore.configuration.database = :mysql
      assert_equal 'Sequel::Mysql2::Database', @connector.database.class.to_s
    end

    should 'return the sqlite database if so defined' do
      DataStore.configuration.database = :sqlite
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

  context 'DataStore Model' do

    setup do
      DataStore.configuration.database = ENV['DB'] || :postgres
      DataStore::Connector.new.reset!
    end

    context 'with added behaviour through Sequel::Model' do

      setup do
        @record = DataStore.model.create(identifier:  1,
                                         type:        'gauge', 
                                         name:        'Electra',
                                         description: 'Actual usage of electra in the home')
      end

      should 'be valid' do
        assert @record
      end

      should 'have added a record to the database' do
        assert_equal 1, DataStore.model.count
      end

      should 'return all attibutes' do
        assert_equal 1, @record.identifier
        assert_equal 'gauge', @record.type
        assert_equal 'Electra', @record.name
        assert_equal 'Actual usage of electra in the home', @record.description
      end

      should 'have timestamps' do
        assert_equal true, @record.created_at.is_a?(Time)
        assert_equal true, @record.updated_at.is_a?(Time)
      end
      
      should 'create a record with a uniq identifier' do
        assert_raise 'Sequel::DatabaseError(<SQLite3::ConstraintException: column identifier is not unique>)' do
          @model.create(identifier: 1, type: 'gauge', name: 'Electra')
        end
      end

      should 'be able to update a record' do
        @record.name = 'Gas'
        @record.save
        assert_equal 'Gas', DataStore.model.order(:created_at).last.name
      end

    end

  end

end